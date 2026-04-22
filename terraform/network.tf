resource "azurerm_virtual_network" "vnet" {
    location = azurerm_resource_group.rg.location
    name = "vnet-${random_pet.naming.id}"
    resource_group_name = azurerm_resource_group.rg.name
    address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "frontend_subnet" {
    name                 = "frontend-subnet-${random_pet.naming.id}"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = var.frontend_subnet_address_prefix
}

resource "azurerm_subnet" "backend_subnet" {
    name                 = "backend-subnet-${random_pet.naming.id}"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = var.backend_subnet_address_prefix
}

resource "azurerm_subnet" "bastion_subnet" {
    name                 = "AzureBastionSubnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = var.bastion_subnet_address_prefix
}

resource "azurerm_public_ip" "bastion_pip" {
    allocation_method = "Static"
    location = azurerm_resource_group.rg.location
    name = "bastion-pip-${random_pet.naming.id}"
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Standard"
}

resource "azurerm_public_ip" "appgateway_pip" {
    allocation_method = "Static"
    location = azurerm_resource_group.rg.location
    name = "appgateway-pip-${random_pet.naming.id}"
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Standard"
}

resource "azurerm_public_ip" "natgateway_pip" {
    allocation_method = "Static"
    location = azurerm_resource_group.rg.location
    name = "natgateway-pip-${random_pet.naming.id}"
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Standard"    
}

resource "azurerm_bastion_host" "bastion" {
    location = azurerm_resource_group.rg.location
    name = "bastion-${random_pet.naming.id}"
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Standard"
    tunneling_enabled = true

    ip_configuration {
        name                 = "bastion-ip-${random_pet.naming.id}"
        subnet_id            = azurerm_subnet.bastion_subnet.id
        public_ip_address_id = azurerm_public_ip.bastion_pip.id
    }
}

resource "azurerm_nat_gateway" "natgateway" {
    location = azurerm_resource_group.rg.location
    name = "natgateway-${random_pet.naming.id}"
    resource_group_name = azurerm_resource_group.rg.name
    sku_name = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "natgateway_pip_association" {
    nat_gateway_id = azurerm_nat_gateway.natgateway.id
    public_ip_address_id = azurerm_public_ip.natgateway_pip.id
}

resource "azurerm_subnet_nat_gateway_association" "natgateway_backend" {
    nat_gateway_id = azurerm_nat_gateway.natgateway.id
    subnet_id = azurerm_subnet.backend_subnet.id    
}