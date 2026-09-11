output "image_name" {
  description = "GHCR image that was pulled."
  value       = docker_image.app.name
}

output "container_name" {
  description = "Local container name."
  value       = docker_container.app.name
}

output "exit_code" {
  description = "Container exit code. 0 means Hello World ran successfully."
  value       = docker_container.app.exit_code
}

output "logs" {
  description = "Container stdout/stderr. Look for Hello World here, or run: docker logs devops-challenge"
  value       = docker_container.app.container_logs
}
