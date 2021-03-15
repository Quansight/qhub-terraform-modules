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

# Gives spawned containers access to the API of the hub
# c.JupyterHub.hub_connect_url = "http://${proxy_public.host}:${proxy_public.port}/hub/api"
c.JupyterHub.hub_connect_ip = "${hub.host}"
c.JupyterHub.hub_connect_port = ${hub.port}

# singleuser notebook defaults
c.KubeSpawner.namespace = "${singleuser.namespace}"
c.KubeSpawner.image = "${singleuser.image}"
c.KubeSpawner.cpu_guarantee = ${singleuser.cpu_guarantee}
c.KubeSpawner.cpu_limit = ${singleuser.cpu_limit}
c.KubeSpawner.mem_guarantee = "${singleuser.mem_guarantee}"
c.KubeSpawner.mem_limit = "${singleuser.mem_limit}"
c.KubeSpawner.default_url = "${singleuser.default_url}"
c.KubeSpawner.pod_name_template = "${singleuser.pod_name_template}"
c.KubeSpawner.node_selector = {"${jupyterlab-node-group.key}": "${jupyterlab-node-group.value}"}

# jupyterhub services
c.JupyterHub.services = [
${join("\n", formatlist("    {'name': '%s', 'api_token': '%s'},", service.names, service.api_tokens))}
]

${extraConfig}
