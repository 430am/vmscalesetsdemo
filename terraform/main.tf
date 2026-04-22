data "azurerm_client_config" "current" {}

resource "random_pet" "naming" {
    separator = ""
    length    = 2
}

resource "azurerm_resource_group" "rg" {
    name     = "${random_pet.naming.id}-rg"
    location = var.location
}

resource "azurerm_user_assigned_identity" "kv_access" {
    location = azurerm_resource_group.rg.location
    name = "kv-access-${random_pet.naming.id}"
    resource_group_name = azurerm_resource_group.rg.name
}