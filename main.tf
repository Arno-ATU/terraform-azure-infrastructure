# Resource Group - Container for all resources


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


# Virtual Network
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

# =================================================
# PUBLIC SUBNETS
#==================================================
# Public Subnet 1 - Availability Zone 1
# Zone 1 provides isolation from Zone 2 for high availability

resource "azurerm_subnet" "public_1" {
  name                 = "subnet-public-az1"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}


# Public Subnet 2 - Availability Zone 2
# If Zone 1 fails, Zone 2 continues serving traffic
# Provides 256 IP addresses (10.0.2.1 - 10.0.2.254)

resource "azurerm_subnet" "public_2" {
  name                 = "subnet-public-az2"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}


# =================================================
# PRIVATE SUBNETS
#==================================================
# Private Subnet 1 - Availability Zone 1
# No direct internet access - only accessible from within the VNet
# Provides a security layer for sensitive data and internal services

resource "azurerm_subnet" "private_1" {
  name                 = "subnet-private-az1"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.10.0/24"]
}


# Private Subnet 2 - Availability Zone 2
# Ensures the database/backend services survive Zone 1 failure
# Paired with private subnet 1 for high availability

resource "azurerm_subnet" "private_2" {
  name                 = "subnet-private-az2"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.20.0/24"]
}