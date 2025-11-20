
# All compute resources: SSH keys and VMs

# =================================================
# SSH KEY INFRASTRUCTURE
# =================================================

# Generate SSH Key Pair
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save Private Key to Local File
resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/ssh-key.pem"
  file_permission = "0600"
}

# ===================================================
# VIRTUAL MACHINE 1 - ZONE 1
# ====================================================

# Public IP for VM1
resource "azurerm_public_ip" "vm1" {
  name                = "pip-vm-web-1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]

  tags = {
    Environment = "Learning"
    Project     = "Terraform-Assignment"
    Student     = var.student_name
    Server      = "WebServer1"
  }
}

# Network Interface for VM1
resource "azurerm_network_interface" "vm1" {
  name                = "nic-vm-web-1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public_1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1.id
  }

  tags = {
    Environment = "Learning"
    Project     = "Terraform-Assignment"
    Student     = var.student_name
    Server      = "WebServer1"
  }
}

# Associate NIC with NSG
resource "azurerm_network_interface_security_group_association" "vm1" {
  network_interface_id      = azurerm_network_interface.vm1.id
  network_security_group_id = azurerm_network_security_group.public.id
}

# Virtual Machine 1
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vm-web-1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  zone                = "1"

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    
    cat > /var/www/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head><title>HA Web Server</title></head>
    <body style="font-family: Arial; margin: 50px;">
      <h1>Web Server 1 - Zone 1</h1>
      <h2>Student: Arno-L00188491</h2>
      <p>MSc DevOps - Terraform Assignment</p>
      <p>This server is running in Availability Zone 1</p>
    </body>
    </html>
    HTML
    
    systemctl enable nginx
    systemctl start nginx
  EOF
  )


  network_interface_ids = [
    azurerm_network_interface.vm1.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "osdisk-vm-web-1"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  disable_password_authentication = true

  tags = {
    Environment = "Learning"
    Project     = "Terraform-Assignment"
    Student     = var.student_name
    Server      = "WebServer1"
    Zone        = "1"
  }
}


# =================================================
# VIRTUAL MACHINE 2 - ZONE 2
# =================================================

# Public IP for VM2
resource "azurerm_public_ip" "vm2" {
  name                = "pip-vm-web-2"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["2"] # Availability Zone 2

  tags = {
    Environment = "Learning"
    Project     = "Terraform-Assignment"
    Student     = var.student_name
    Server      = "WebServer2"
  }
}

# Network Interface for VM2
resource "azurerm_network_interface" "vm2" {
  name                = "nic-vm-web-2"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public_2.id # Zone 2 subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm2.id
  }

  tags = {
    Environment = "Learning"
    Project     = "Terraform-Assignment"
    Student     = var.student_name
    Server      = "WebServer2"
  }
}

# Associate NIC with NSG
resource "azurerm_network_interface_security_group_association" "vm2" {
  network_interface_id      = azurerm_network_interface.vm2.id
  network_security_group_id = azurerm_network_security_group.public.id
}

# Virtual Machine 2
resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "vm-web-2"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  zone                = "2" # Availability Zone 2

  network_interface_ids = [
    azurerm_network_interface.vm2.id,
  ]

  # Uses same SSH key as VM1
  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "osdisk-vm-web-2"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  disable_password_authentication = true

  tags = {
    Environment = "Learning"
    Project     = "Terraform-Assignment"
    Student     = var.student_name
    Server      = "WebServer2"
    Zone        = "2"
  }
}