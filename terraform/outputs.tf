output "image_name" {
  description = "GHCR image that was pulled."
  value       = module.app.image_name
}

output "container_name" {
  description = "Local container name."
  value       = module.app.container_name
}

output "exit_code" {
  description = "Container exit code. 0 means Hello World ran successfully."
  value       = module.app.exit_code
}

output "logs" {
  description = "Container logs."
  value       = module.app.logs
}
