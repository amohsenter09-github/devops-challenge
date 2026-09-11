# Second app from the registry. Copy this file for each new image.
# Use a unique container_name. Use -state so this apply does not replace the first app.
# terraform apply -var-file=application-2.tfvars -state=application-2.tfstate
image_name     = "ghcr.io/amohsenter09-github/devops-challenge"
image_tag      = "latest"
container_name = "devops-challenge-2"
