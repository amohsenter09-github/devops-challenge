output "apps" {
  description = "Per-container image, exit code, and logs."
  value = {
    for name, instance in module.app : name => {
      image_name     = instance.image_name
      container_name = instance.container_name
      exit_code      = instance.exit_code
      logs           = instance.logs
    }
  }
}
