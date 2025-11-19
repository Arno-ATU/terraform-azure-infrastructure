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


# ==============================================
# NSG ASSOCIATIONS - APPLY FIREWALLS TO SUBNETS
# ===============================================

# Associate public NSG with public subnet 1
# This applies the firewall rules to all resources in this subnet

resource "azurerm_subnet_network_security_group_association" "public_1" {
  subnet_id                 = azurerm_subnet.public_1.id
  network_security_group_id = azurerm_network_security_group.public.id
}

# Associate public NSG with public subnet 2
# Both public subnets get the same security rules

resource "azurerm_subnet_network_security_group_association" "public_2" {
  subnet_id                 = azurerm_subnet.public_2.id
  network_security_group_id = azurerm_network_security_group.public.id
}

# Associate private NSG with private subnet 1
# Applies restrictive rules to the backend tier

resource "azurerm_subnet_network_security_group_association" "private_1" {
  subnet_id                 = azurerm_subnet.private_1.id
  network_security_group_id = azurerm_network_security_group.private.id
}

# Associate private NSG with private subnet 2
# Bothh of the  private subnets get the same security rules

resource "azurerm_subnet_network_security_group_association" "private_2" {
  subnet_id                 = azurerm_subnet.private_2.id
  network_security_group_id = azurerm_network_security_group.private.id
}



# =========================================================
# SSH KEY FOR VM ACCESS
# =========================================================

# Generate SSH Key Pair
# This creates a 4096-bit RSA key pair automatically
# The public key will go on the VMs, private key stays on local computer

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save Private Key to Local File
# This saves the private key so thhat we can use it with: ssh -i ssh-key.pem
# File permissions: 0600 means only YOU/WE can read/write it (security!)
# Public key is stored in Terraform state (for VM creation)

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/ssh-key.pem"
  file_permission = "0600"
}