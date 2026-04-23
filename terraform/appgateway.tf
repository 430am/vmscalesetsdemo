# Azure Application Gateway - Locals Block
locals {
  # Generics
  frontend_port_name = "${azurerm_virtual_network.vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
  redirect_configuration_name = "${azurerm_virtual_network.vnet.name}-redir"

  # App1
  app1_backend_pool_name = "${azurerm_virtual_network.vnet.name}-app1-bepool"
  app1_http_settings_name = "${azurerm_virtual_network.vnet.name}-app1-httpsettings"
  app1_probe_name = "${azurerm_virtual_network.vnet.name}-app1-probe"

  # HTTP Listener - Port 80
  listener_name_http = "${azurerm_virtual_network.vnet.name}-lstn-http"
  request_routing_rule_name_http = "${azurerm_virtual_network.vnet.name}-rout-http"
  frontend_port_name_http = "${azurerm_virtual_network.vnet.name}-feport-http"

  # HTTPS Listener - Port 443
  listener_name_https = "${azurerm_virtual_network.vnet.name}-lstn-https"
  request_routing_rule_name_https = "${azurerm_virtual_network.vnet.name}-rout-https"
  frontend_port_name_https = "${azurerm_virtual_network.vnet.name}-feport-https"
}

resource "azurerm_application_gateway" "web_ag" {
  location = var.location
  name = "${random_pet.naming.id}-ag"
  resource_group_name = azurerm_resource_group.rg.name
  
  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 0
    max_capacity = 2
  }

  gateway_ip_configuration {
    name = "gateway-ip-config"
    subnet_id = azurerm_subnet.frontend_subnet.id
  }

  frontend_ip_configuration {
    name = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgateway_pip
  }

  frontend_port {
    name = local.frontend_port_name_http
    port = 80
  }

  frontend_port {
    name = local.frontend_port_name_https
    port = 443
  }
  
  http_listener {
    name = local.listener_name_http
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name = local.frontend_port_name_http
    protocol = "Http"
  }

  request_routing_rule {
    name = local.request_routing_rule_name_http
    rule_type = "Basic"
    http_listener_name = local.frontend_port_name_http
    redirect_configuration_name = local.redirect_configuration_name
  }

  redirect_configuration {
    name = local.redirect_configuration_name
    redirect_type = "Permanent"
    target_listener_name = local.listener_name_https
    include_path = true
    include_query_string = true
  }
}