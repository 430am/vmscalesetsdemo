resource "azurerm_key_vault" "kv" {
    location = azurerm_resource_group.rg.location
    name = "kv${random_pet.naming.id}"
    resource_group_name = azurerm_resource_group.rg.name
    sku_name = "Standard"
    tenant_id = data.azurerm_client_config.current.tenant_id
    soft_delete_retention_days = 7
    purge_protection_enabled = false
    rbac_authorization_enabled = true
}

resource "azurerm_role_assignment" "kv_admin" {
    principal_id = data.azurerm_client_config.current.object_id
    scope = azurerm_key_vault.kv.id
    role_definition_name = "Key Vault Administrator"

    depends_on = [ azurerm_key_vault.kv ]
}

resource "azurerm_key_vault_secret" "private_key" {
    key_vault_id = azurerm_key_vault.kv.id
    name = "openssh-${random_pet.naming.id}-private-key"
    value_wo = ephemeral.tls_private_key.ssh-vm-priv.private_key_openssh
    value_wo_version = 1
    
    depends_on = [ azurerm_role_assignment.kv_admin ]
}

resource "azurerm_key_vault_secret" "public_key" {
    key_vault_id = azurerm_key_vault.kv.id
    name = "openssh-${random_pet.naming.id}-public-key"
    value_wo = ephemeral.tls_private_key.ssh-vm-priv.public_key_openssh
    value_wo_version = 1
    
    depends_on = [ azurerm_role_assignment.kv_admin ]
}

