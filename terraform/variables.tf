variable "image_name" {
  description = "GHCR image without tag. Default matches the image CI pushes."
  type        = string
  default     = "ghcr.io/amohsenter09-github/devops-challenge"
}

variable "image_tag" {
  description = "Image tag to pull. Use latest or a CI sequence number such as 5."
  type        = string
  default     = "latest"
}

variable "container_name" {
  description = "Name of the local container Terraform creates."
  type        = string
  default     = "devops-challenge"
}
