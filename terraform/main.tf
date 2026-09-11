# One app per apply. Pass a tfvars file for that registry image.
# Many apps = many tfvars files (application.tfvars, application-2.tfvars, ...).
module "app" {
  source = "./modules/container-app"

  image_name     = var.image_name
  image_tag      = var.image_tag
  container_name = var.container_name
}

