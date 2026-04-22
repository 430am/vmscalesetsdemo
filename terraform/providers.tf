terraform {
  required_version = ">= 1.14"

  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">= 4.68.0"
    }
    random = {
        source = "hashicorp/random"
        version = ">= 3.8.0"
    }
    tls = {
        source = "hashicorp/tls"
        version = ">= 4.2.1"
    }
    cloudinit = {
        source = "hashicorp/cloudinit"
        version = ">= 2.3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
      purge_soft_deleted_secrets_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine_scale_set {
      force_delete = true
    }
  }
}