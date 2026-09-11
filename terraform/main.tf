locals {
  image = "${var.image_name}:${var.image_tag}"
}

# Read the published digest so Terraform re-pulls when CI pushes a new :latest.
data "docker_registry_image" "app" {
  name = local.image
}

# Pull the image from GHCR. Does not build locally.
resource "docker_image" "app" {
  name          = data.docker_registry_image.app.name
  keep_locally  = true
  pull_triggers = [data.docker_registry_image.app.sha256_digest]
}

# This app prints Hello World and exits. It is not a long-running service.
# must_run = false: Terraform accepts an exited container as success.
# rm = false: keep the stopped container so Terraform can still read it.
resource "docker_container" "app" {
  name  = var.container_name
  image = docker_image.app.image_id

  must_run = false
  restart  = "no"
  rm       = false
  attach   = true
  logs     = true
}
