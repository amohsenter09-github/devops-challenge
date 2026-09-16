variable "image_name" {
  description = "GHCR image without tag."
  type        = string
  default     = "ghcr.io/amohsenter09-github/devops-challenge"
}

variable "image_tag" {
  description = "Image tag CI publishes on this branch."
  type        = string
  default     = "scenario-v1"
}

variable "container_name" {
  description = "Name of the local container Terraform creates."
  type        = string
  default     = "devops-challenge"
}

variable "host_port" {
  description = "Host port mapped to the app (container port 8080)."
  type        = number
  default     = 8080
}
