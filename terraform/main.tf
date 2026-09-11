# One module call per app. Add a row in var.apps to run another container.
module "app" {
  source   = "./modules/container-app"
  for_each = var.apps

  image_name     = each.value.image_name
  image_tag      = each.value.image_tag
  container_name = each.key
}
