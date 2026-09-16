variable "image_name" {
  description = "GHCR image without tag."
  type        = string
}

variable "image_tag" {
  description = "Image tag to pull."
  type        = string
}

variable "container_name" {
  description = "Local Docker container name."
  type        = string
}

variable "host_port" {
  description = "Host port mapped to container port 8080."
  type        = number
}
