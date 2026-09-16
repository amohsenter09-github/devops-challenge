locals {
  image = "${var.image_name}:${var.image_tag}"
}

# Read the published digest so Terraform re-pulls when CI pushes a new scenario-v1 image.
data "docker_registry_image" "app" {
  name = local.image
}

# Pull from GHCR. Does not build locally.
resource "docker_image" "app" {
  name          = data.docker_registry_image.app.name
  keep_locally  = true
  pull_triggers = [data.docker_registry_image.app.sha256_digest]
}

# Keep the web app running and map host port 8080.
resource "docker_container" "app" {
  name  = var.container_name
  image = docker_image.app.image_id

  must_run = true
  restart  = "unless-stopped"

  ports {
    internal = 8080
    external = var.host_port
  }
}
