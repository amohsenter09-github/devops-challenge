variable "image_name" {
  description = "GHCR image without tag. Set in application.tfvars."
  type        = string
}

variable "image_tag" {
  description = "Image tag. Set in application.tfvars."
  type        = string
}

variable "container_name" {
  description = "Local container name. Set in application.tfvars."
  type        = string
}
