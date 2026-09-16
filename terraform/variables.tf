variable "image_name" {
  description = "GHCR image without tag. Set in scenario-v1.tfvars."
  type        = string
}

variable "image_tag" {
  description = "Image tag. Set in scenario-v1.tfvars."
  type        = string
}

variable "container_name" {
  description = "Local container name. Set in scenario-v1.tfvars."
  type        = string
}

variable "host_port" {
  description = "Host port mapped to container port 8080. Set in scenario-v1.tfvars."
  type        = number
}
