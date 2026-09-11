output "image_name" {
  description = "Image that was pulled."
  value       = docker_image.this.name
}

output "container_name" {
  description = "Local container name."
  value       = docker_container.this.name
}

output "exit_code" {
  description = "Container exit code. 0 means the app ran successfully."
  value       = docker_container.this.exit_code
}

output "logs" {
  description = "Container logs."
  value       = docker_container.this.container_logs
}
