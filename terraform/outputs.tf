output "image_name" {
  description = "GHCR image that was pulled."
  value       = module.app.image_name
}

output "container_name" {
  description = "Local container name."
  value       = module.app.container_name
}

output "url" {
  description = "Open this URL locally after terraform apply."
  value       = module.app.url
}
