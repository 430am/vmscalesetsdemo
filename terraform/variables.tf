variable "location" {
  description = "The Azure region in which to create resources."
  type        = string
  default     = "centralus"
}

variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "frontend_subnet_address_prefix" {
  description = "The address prefix for the frontend subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "backend_subnet_address_prefix" {
  description = "The address prefix for the backend subnet."
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "bastion_subnet_address_prefix" {
  description = "The address prefix for the bastion subnet."
  type        = list(string)
  default     = ["10.0.3.0/26"]
}

variable "vmss_instance_count" {
  description = "The default number of instances in the Virtual Machine Scale Set."
  type        = number
  default     = 2
}

variable "vmss_sku_name" {
  description = "The SKU name for the Virtual Machine Scale Set."
  type        = string
  default     = "Standard_D2als_v6"
}