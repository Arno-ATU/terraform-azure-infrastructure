
# Resource Group - Container for all our resources
# Azure requires all resources to belong to a resource group

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Learning"
    Project     = "Terraform-Assignment"
    ManagedBy   = "Terraform"
    Student     = var.student_name
  }
}

# Virtual Network - Its our private network in Azure
# Why: VNet provides isolated network space with CIDR 10.0.0.0/16
# This gives us 65,536 IP addresses to work with

resource "azurerm_virtual_network" "main" {
  name                = "vnet-ha-webapp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_address_space

  tags = {
    Environment = "Learning"
    Project     = "Terraform-Assignment"
    Student     = var.student_name
  }
}
