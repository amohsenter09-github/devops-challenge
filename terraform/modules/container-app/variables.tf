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
