# Pull and run one GHCR image.
# Use workspaces + matching tfvars: select "dev" + -var-file=dev.tfvars, or "prod" + prod.tfvars.
module "app" {
  source = "./modules/container-app"

  image_name     = var.image_name
  image_tag      = var.image_tag
  image_digest   = var.image_digest
  container_name = var.container_name
  host_port      = var.host_port
  hello_color    = var.hello_color
  hello_emoji    = var.hello_emoji
}
