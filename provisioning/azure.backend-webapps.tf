locals {
  webapp_docker_image_list = [
    "nginx",
    "httpd",
  ]
}

resource "azurerm_service_plan" "app" {
  for_each            = toset(local.webapp_docker_image_list)
  name                = "${var.project_unique_id}-app-${each.key}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  # See also https://azure.microsoft.com/en-us/pricing/details/app-service/windows/#pricing
  # > The Basic service plan with Linux runtime environments supports Web App for Containers.
  sku_name = "B1"
}

resource "azurerm_linux_web_app" "app" {
  for_each            = toset(local.webapp_docker_image_list)
  name                = "${var.project_unique_id}-app-${each.key}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  service_plan_id     = azurerm_service_plan.app[each.key].id
  site_config {
    application_stack {
      docker_image     = each.key
      docker_image_tag = "latest"
    }
  }
}
