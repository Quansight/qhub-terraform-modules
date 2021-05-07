# QHub Terraform Modules

NOTE *The modules are shortly to be moved into qhub repo directly so this repo may not be in use by the time you are reading this.*

Repository to manage deployments of Quansight and customer terraform
modules. This repository holds the modules (not deployments) to allow
deployments to depend on versioned sets of the modules. No secrets
will ever be stored in this module.

# Providers

 - cloud
   - Amazon Web Services
   - Digital Ocean
   - Google Cloud Provider
   - Azure

 - Services
   - Kubernetes
   - Postgresql
   - Dask Gateway
   - jupyterlab-ssh
   - conda-store
   - prefect
   - qhub
