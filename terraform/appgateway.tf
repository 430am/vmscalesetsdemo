# Azure Application Gateway - Locals Block

locals {
  # Generics
  frontend_port_name = "${azurerm_virtual_network.vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.name}-feip"
  listener_name = "${azurerm_virtual_network.name}-httplstn"
}
