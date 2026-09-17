locals {
  # Pin by digest when set; otherwise pull by floating tag (dev / prod).
  image = var.image_digest != "" ? "${var.image_name}@${var.image_digest}" : "${var.image_name}:${var.image_tag}"
}

# Ask GHCR for the current digest so a new push of this tag is pulled on apply.
data "docker_registry_image" "this" {
  name = local.image
}

# Pull from GHCR. This module does not build the image.
resource "docker_image" "this" {
  name          = data.docker_registry_image.this.name
  keep_locally  = false
  pull_triggers = [data.docker_registry_image.this.sha256_digest]
}

# Keep the web app running and map host port 8080.
resource "docker_container" "this" {
  name  = var.container_name
  image = docker_image.this.image_id

  must_run = true
  restart  = "unless-stopped"

  ports {
    internal = 8080
    external = var.host_port
  }
}
