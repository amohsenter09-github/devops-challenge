# One registry app. Copy this file for another app, change the three values, then:
# terraform apply -var-file=application.tfvars
# terraform apply -var-file=application-2.tfvars -state=application-2.tfstate
image_name     = "ghcr.io/amohsenter09-github/devops-challenge"
image_tag      = "latest"
container_name = "devops-challenge"
