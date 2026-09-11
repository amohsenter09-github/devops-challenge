variable "image_name" {
  description = "GHCR image without tag."
  type        = string
}

variable "image_tag" {
  description = "Image tag to pull (latest or a CI sequence number)."
  type        = string
  default     = "latest"
}

variable "container_name" {
  description = "Docker container name. Must be unique on the machine."
  type        = string
}
