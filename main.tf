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


# =========================================================
# NETWORK SECURITY GROUPS (NSGs) - FIREWALLS
# =========================================================



# Publicc Subnet NSG
# ==================

# This NSG will be applied to both public subnets

resource "azurerm_network_security_group" "public" {
  name                = "nsg-public-subnets"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = "Learning"
    Project     = "Terraform-Assignment"
    Student     = var.student_name
  }
}

# Inbound Rule: Allow HTTP traffic from internet
# Priority: Lower number = higher priority (100 is processed first)
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "AllowHTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.public.name
}


# Inbound Rule: Allow SSH for server management
# We nneed to be able to log in and manage the servers
# In production, this should be restricted to specific IPs

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "AllowSSH"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.public.name
}



# Private Subnet NSG
# ==================

# This NSG will be applied to both private subnets
# Only allows traffic from public subnets

resource "azurerm_network_security_group" "private" {
  name                = "nsg-private-subnets"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = "Learning"
    Project     = "Terraform-Assignment"
    Student     = var.student_name
  }
}

# Inbound Rule: Allow traffic from public subnets only
# Note: Azure denies all other inbound traffic by default
# No explicit deny rule needed - Azure's default deny provides adequate security

resource "azurerm_network_security_rule" "allow_from_public" {
  name                        = "AllowFromPublicSubnets"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = ["10.0.1.0/24", "10.0.2.0/24"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.private.name
}
