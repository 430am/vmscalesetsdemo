data "azurerm_key_vault_secret" "vm_public_key" {
    key_vault_id = azurerm_key_vault.kv.id
    name = azurerm_key_vault_secret.public_key.name
    
}

resource "azurerm_orchestrated_virtual_machine_scale_set" "vmss" {
    location = var.location
    name = "${random_pet.naming.id}-vmss"
    platform_fault_domain_count = 1
    resource_group_name = azurerm_resource_group.rg.name
    sku_name = var.vmss_sku_name
    instances = var.vmss_instance_count

    os_disk {
      storage_account_type = "Premium_LRS"
      caching = "ReadWrite"
    }

    source_image_reference {
      publisher = "Canonical"
      offer = "ubuntu-24_04-lts"
      sku = "server"
      version = "latest"
    }

    user_data_base64 = base64encode(file("./config/installweb.yaml"))

    os_profile {
      linux_configuration {
        disable_password_authentication = true
        admin_username = "ladmin"
        admin_ssh_key {
          username = "ladmin"
          public_key = data.azurerm_key_vault_secret.vm_public_key.value
        }
      }
    }

    network_interface {
      name = "nic"
      primary = true
      enable_accelerated_networking = true

      ip_configuration {
        name = "ipconfig"
        primary = true
        subnet_id = azurerm
      }
    }
}