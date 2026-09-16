output "image_name" {
  description = "GHCR image that was pulled."
  value       = docker_image.app.name
}

output "container_name" {
  description = "Local container name."
  value       = docker_container.app.name
}

output "url" {
  description = "Open this URL locally after terraform apply."
  value       = "http://127.0.0.1:${var.host_port}/"
}
