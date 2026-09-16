output "image_name" {
  description = "Image that was pulled."
  value       = docker_image.this.name
}

output "container_name" {
  description = "Local container name."
  value       = docker_container.this.name
}

output "url" {
  description = "Local URL for the web app."
  value       = "http://localhost:${var.host_port}/"
}
