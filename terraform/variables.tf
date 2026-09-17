variable "image_name" {
  description = "GHCR image without tag. Set in the env tfvars file."
  type        = string
}

variable "image_tag" {
  description = "Image tag (dev or prod). Ignored when image_digest is set."
  type        = string
}

variable "image_digest" {
  description = "Optional pin: sha256:... If set, pull by digest instead of tag."
  type        = string
  default     = ""
}

variable "container_name" {
  description = "Local container name. Set in the env tfvars file."
  type        = string
}

variable "host_port" {
  description = "Host port mapped to container port 8080."
  type        = number
}

variable "hello_color" {
  description = "CSS color for Hello World (passed as HELLO_COLOR)."
  type        = string
}

variable "hello_emoji" {
  description = "Emoji shown next to Hello World (passed as HELLO_EMOJI)."
  type        = string
}
