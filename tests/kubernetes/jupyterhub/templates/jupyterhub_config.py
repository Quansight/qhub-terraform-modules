# based on zero to jupyterhub
# https://github.com/jupyterhub/zero-to-jupyterhub-k8s/blob/master/jupyterhub/files/hub/jupyterhub_config.py
import json
import os

# Configure JupyterHub to use the curl backend for making HTTP requests,
# rather than the pure-python implementations. The default one starts
# being too slow to make a large number of requests to the proxy API
# at the rate required.
from tornado.httpclient import AsyncHTTPClient
AsyncHTTPClient.configure("tornado.curl_httpclient.CurlAsyncHTTPClient")

c.JupyterHub.spawner_class = 'kubespawner.KubeSpawner'

# Connect to a proxy running in a different pod
c.ConfigurableHTTPProxy.api_url = 'http://${proxy_api.host}:${proxy_api.port}'
c.ConfigurableHTTPProxy.should_start = False

# Do not shut down user pods when hub is restarted
c.JupyterHub.cleanup_servers = False

# Check that the proxy has routes appropriately setup
c.JupyterHub.last_activity_interval = 60

# Don't wait at all before redirecting a spawning user to the progress page
c.JupyterHub.tornado_settings = {
    'slow_spawn_timeout': 0,
}

# Configure persistent sqlite jupyterhub database
c.JupyterHub.db_url = "sqlite:///jupyterhub.sqlite"

# Set jupyterhub proxy ip/hostname
c.JupyterHub.ip = "${proxy_public.host}"
c.JupyterHub.port = ${proxy_public.port}

# the hub should listen on all interfaces, so the proxy can access it
c.JupyterHub.hub_ip = '0.0.0.0'

# Set default namespace for pods to be launched as
c.KubeSpawner.namespace = "${singleuser.namespace}"

# Gives spawned containers access to the API of the hub
c.JupyterHub.hub_connect_ip = "${hub.host}"
c.JupyterHub.hub_connect_port = ${hub.port}

# convert {"service1": "token1", "service2": "token2"} into
# [{"name": "service1", "api_token": "token1"}, ...]
# due to inflexibility of terraform language
# TODO come up with more elegant way to add services
c.JupyterHub.services = [{"name": k, "api_token": v} for k, v in json.loads(os.environ['JUPYTERHUB_API_SERVICE_TOKENS']).items()]

${extraConfig}

# HUB_USER_MAPPING = {{ cookiecutter.security.users }}
# QHUB_GROUP_MAPPING = {{ cookiecutter.security.groups }}
# QHUB_PROFILES = {{ cookiecutter.profiles.jupyterlab }}

# def qhub_generate_nss_files():
#     passwd = []
#     passwd_format = '{username}:x:{uid}:{gid}:{username}:/home/jovyan:/bin/bash'
#     for username, config in QHUB_USER_MAPPING.items():
#         uid = config['uid']
#         gid = QHUB_GROUP_MAPPING[config['primary_group']]['gid']
#         passwd.append(passwd_format.format(username=username, uid=uid, gid=gid))

#     group = []
#     group_format = '{groupname}:x:{gid}:'
#     for groupname, config in QHUB_GROUP_MAPPING.items():
#         gid = config['gid']
#         group.append(group_format.format(groupname=groupname, gid=gid))

#     return '\n'.join(passwd), '\n'.join(group)


# def qhub_list_admins(users):
#     return [k for k,v in users.items() if v['primary_group'] == 'admin']


# def qhub_list_users(users):
#     return [k for k,v in users.items() if v['primary_group'] != 'admin']


# def qhub_list_user_groups(username):
#     user = QHUB_USER_MAPPING[username]
#     return set([user['primary_group']] + user.get('secondary_groups', []))


# def qhub_configure_profile(username, safe_username, profile):
#     user = QHUB_USER_MAPPING[username]
#     uid = user['uid']
#     primary_gid = QHUB_GROUP_MAPPING[user['primary_group']]['gid']
#     secondary_gids = [QHUB_GROUP_MAPPING[_]['gid'] for _ in user.get('secondary_groups', [])]

#     profile['kubespawner_override']['environment'] = {
#        'LD_PRELOAD': 'libnss_wrapper.so',
#        'NSS_WRAPPER_PASSWD': '/tmp/passwd',
#        'NSS_WRAPPER_GROUP': '/tmp/group',
#        'HOME': '/home/jovyan',
#     }

#     passwd, group = qhub_generate_nss_files()
#     profile['kubespawner_override']['lifecycle_hooks'] = {
#         "postStart": {
#             "exec": {
#                 "command": ["/bin/sh", "-c", (
#                      "echo '{passwd}' > /tmp/passwd && "
#                      "echo '{group}' > /tmp/group && "
#                      "ln -sfn /home/shared /home/jovyan/shared"
#                 ).format(passwd=passwd, group=group)]
#             }
#         }
#     }

#     profile['kubespawner_override']['init_containers'] = [
#         {
#              "name": "init-nfs",
#              "image": "busybox:1.31",
#              "command": ["sh", "-c", ' && '.join([
#                   "mkdir -p /mnt/home/{username}",
#                   "chmod 700 /mnt/home/{username}",
#                   "chown {uid}:{primary_gid} /mnt/home/{username}",
#                   "mkdir -p /mnt/home/shared",
#                   "chmod 777 /mnt/home/shared"
#              ] + ["mkdir -p /mnt/home/shared/{groupname} && chmod 770 /mnt/home/shared/{groupname} && chown 0:{gid} /mnt/home/shared/{groupname}".format(groupname=groupname, gid=config['gid']) for groupname, config in QHUB_GROUP_MAPPING.items()]).format(username=safe_username, uid=uid, primary_gid=primary_gid)],
#              "securityContext": {"runAsUser": 0},
#              "volumeMounts": [{"mountPath": "/mnt", "name": "home"}]
#         }
#     ]

#     profile['kubespawner_override']['uid'] = uid
#     profile['kubespawner_override']['gid'] = primary_gid
#     profile['kubespawner_override']['supplemental_gids'] = secondary_gids
#     profile['kubespawner_override']['fs_gid'] = primary_gid
#     return profile

# def qhub_list_available_profiles(username):
#     import escapism
#     import string
#     safe_chars = set(string.ascii_lowercase + string.digits)
#     safe_username = escapism.escape(username, safe=safe_chars, escape_char='-').lower()

#     exclude_keys = {'users', 'groups'}

#     groups = qhub_list_user_groups(username)

#     available_profiles = []
#     for profile in QHUB_PROFILES:
#         filtered_profile = qhub_configure_profile(username, safe_username, {k: v for k,v in profile.items() if k not in exclude_keys})

#         if 'users' in profile:
#             if username in profile['users']:
#                 available_profiles.append(filtered_profile)
#         elif 'groups' in profile:
#             if len(groups & set(profile['groups'])) != 0:
#                 available_profiles.append(filtered_profile)
#         else:
#             available_profiles.append(filtered_profile)

#     return available_profiles

# c.JupyterHub.admin_access = True
# c.Authenticator.admin_users = qhub_list_admins(QHUB_USER_MAPPING)
# c.Authenticator.whitelist = qhub_list_users(QHUB_USER_MAPPING)

# async def custom_options_form(self):
#     self.profile_list = qhub_list_available_profiles(self.user.name)

#     # Let KubeSpawner inspect profile_list and decide what to return
#     return self._options_form_default()


# c.KubeSpawner.options_form = custom_options_form
# c.LocalProcessSpawner.shell_cmd = ['bash', '-l', '-c']
