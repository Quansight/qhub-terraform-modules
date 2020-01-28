# Quansight Terraform Modules

Repository to manage deployments of Quansight and customer terraform
modules. This repository holds the modules (not deployments) to allow
deployments to depend on versioned sets of the modules. No secrets
will ever be stored in this module.

# Providers

 - cloud
   - aws
   - digitalocean
 - applications
   - kuberentes
   - postgresql

# Motivation

Quansight manages several infrastructure deployments: biotraceit,
datum, and audioeye at the moment. All have slightly different
requirements and the infrastructure deployment/maintenance becomes
quite a burden. Ideally as this matures we will have CI/CD manage all
our deployments (it is not far away). This should significally reduce
the burden of bringing up new people to help manage infrastructure and
deployments. For advanced users provided a disciplined and automate
all the repetitive steps.

