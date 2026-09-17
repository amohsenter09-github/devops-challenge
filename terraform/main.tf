# Pull and run one GHCR image. Values come from dev.tfvars or prod.tfvars.
module "app" {
  source = "./modules/container-app"

  image_name     = var.image_name
  image_tag      = var.image_tag
  image_digest   = var.image_digest
  container_name = var.container_name
  host_port      = var.host_port
}
