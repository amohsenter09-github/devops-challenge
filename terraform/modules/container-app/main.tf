# Module inputs (kept here so the Terraform language server sees them with usages).
variable "image_name" {
  description = "GHCR image without tag."
  type        = string
}

variable "image_tag" {
  description = "Image tag. Ignored when image_digest is set."
  type        = string
}

variable "image_digest" {
  description = "Optional pin: sha256:... If set, pull by digest instead of tag."
  type        = string
  default     = ""
}

variable "container_name" {
  description = "Local Docker container name."
  type        = string
}

variable "host_port" {
  description = "Host port mapped to container port 8080."
  type        = number
}

variable "hello_color" {
  description = "CSS color for Hello World (HELLO_COLOR)."
  type        = string
}

variable "hello_emoji" {
  description = "Emoji shown next to Hello World (HELLO_EMOJI)."
  type        = string
}

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
# HELLO_* come from tfvars (mirrored in env/dev.env and env/prod.env).
resource "docker_container" "this" {
  name  = var.container_name
  image = docker_image.this.image_id

  must_run = true
  restart  = "unless-stopped"

  env = [
    "HELLO_COLOR=${var.hello_color}",
    "HELLO_EMOJI=${var.hello_emoji}",
  ]

  ports {
    internal = 8080
    external = var.host_port
  }
}
