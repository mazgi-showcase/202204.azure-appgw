resource "azurerm_public_ip" "for_main_appgw" {
  name                = "${var.project_unique_id}-for-main-appgw"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

locals {
  backend_address_pool_name      = "backend0"
  backend_http_settings_name     = "setting0"
  frontend_ip_configuration_name = "ip_config0"
  frontend_port_name             = "port_http"
  probe_name                     = "probe0"
}
resource "azurerm_application_gateway" "main" {
  name                = "${var.project_unique_id}-main"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  backend_address_pool {
    name = local.backend_address_pool_name
    fqdns = [
      for webapp_name in var.webapp_name_list : azurerm_linux_web_app.app[webapp_name].default_hostname
    ]
  }
  backend_http_settings {
    name                                = local.backend_http_settings_name
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    probe_name                          = local.probe_name
    pick_host_name_from_backend_address = true
  }
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.for_main_appgw.id
  }
  frontend_port {
    name = local.frontend_port_name
    port = 80
  }
  gateway_ip_configuration {
    name      = "gw_ip_config0"
    subnet_id = azurerm_subnet.appgw.id
  }
  http_listener {
    name                           = "basic_http"
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }
  probe {
    name                                      = local.probe_name
    protocol                                  = "Http"
    path                                      = "/"
    interval                                  = 30
    unhealthy_threshold                       = 3
    timeout                                   = 30
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = ["200-399"]
      body        = ""
    }
  }

  request_routing_rule {
    name                       = "rule0"
    rule_type                  = "Basic"
    http_listener_name         = "basic_http"
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_settings_name
  }
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
}

resource "azurerm_monitor_diagnostic_setting" "for_main_appgw" {
  name                       = "${var.project_unique_id}-for-main-appgw"
  target_resource_id         = azurerm_application_gateway.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  log {
    category = "ApplicationGatewayAccessLog"
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "ApplicationGatewayFirewallLog"
    enabled  = false
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "ApplicationGatewayPerformanceLog"
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
}
