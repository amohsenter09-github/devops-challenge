# One app. Image name, tag, and container name come from application.tfvars.
module "app" {
  source = "./modules/container-app"

  image_name     = var.image_name
  image_tag      = var.image_tag
  container_name = var.container_name
}
