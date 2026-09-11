locals {
  image = "${var.image_name}:${var.image_tag}"
}

# Ask GHCR for the current digest so a new :latest is pulled on the next apply.
data "docker_registry_image" "this" {
  name = local.image
}

# Pull from the registry. This module does not build the image.
resource "docker_image" "this" {
  name          = data.docker_registry_image.this.name
  keep_locally  = true
  pull_triggers = [data.docker_registry_image.this.sha256_digest]
}

# One-shot container: print output and exit. Not a long-running service.
resource "docker_container" "this" {
  name  = var.container_name
  image = docker_image.this.image_id

  must_run = false
  restart  = "no"
  rm       = false
  attach   = true
  logs     = true
}
