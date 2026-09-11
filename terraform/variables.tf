variable "apps" {
  description = "Containers to run locally. Map key = container name (must be unique). Add another entry to run another app."
  type = map(object({
    image_name = string
    image_tag  = optional(string, "latest")
  }))
  default = {
    devops-challenge = {
      image_name = "ghcr.io/amohsenter09-github/devops-challenge"
      image_tag  = "latest"
    }
  }
}
