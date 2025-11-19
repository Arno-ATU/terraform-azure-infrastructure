
# All networking resources: VNet and Subnets

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

# =============================================
# PUBLIC SUBNETS
# =============================================

# Public Subnet 1 - Availability Zone 1
resource "azurerm_subnet" "public_1" {
  name                 = "subnet-public-az1"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Public Subnet 2 - Availability Zone 2
resource "azurerm_subnet" "public_2" {
  name                 = "subnet-public-az2"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# =================================================
# PRIVATE SUBNETS
# =================================================

# Private Subnet 1 - Availability Zone 1
resource "azurerm_subnet" "private_1" {
  name                 = "subnet-private-az1"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.10.0/24"]
}

# Private Subnet 2 - Availability Zone 2
resource "azurerm_subnet" "private_2" {
  name                 = "subnet-private-az2"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.20.0/24"]
}