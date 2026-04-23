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

resource "azurerm_key_vault_certificate" "sslcert" {
    key_vault_id = azurerm_key_vault.kv.id
    name = "sslcert-${random_pet.naming.id}"
    
    certificate_policy {
      issuer_parameters {
        name = "Self"
      }

      key_properties {
        exportable = true
        key_size = 4096
        key_type = "RSA"
        reuse_key = true
      }

      lifetime_action {
        action {
          action_type = "AutoRenew"
        }
        trigger {
          days_before_expiry = 30
        }
      }

      secret_properties {
        content_type = "application/x-pkcs12"
      }

      x509_certificate_properties {
        extended_key_usage = [ "1.3.6.1.5.5.7.3.1" ]

        key_usage = [ 
            "cRLSign",
            "dataEncipherment",
            "digitalSignature",
            "keyAgreement",
            "keyCertSign",
            "keyEncipherment"
         ]

         subject = "CN=mydemo.local"
         validity_in_months = 1
      }
    }
}