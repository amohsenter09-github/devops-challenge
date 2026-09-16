# Pull and run one GHCR image. Values come from scenario-v1.tfvars.
module "app" {
  source = "./modules/container-app"

  image_name     = var.image_name
  image_tag      = var.image_tag
  container_name = var.container_name
  host_port      = var.host_port
}
