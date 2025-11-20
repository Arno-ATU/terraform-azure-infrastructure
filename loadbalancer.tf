# =================================================
# LOAD BALANCER + Public IP
# =================================================

# Public IP for Load Balancer
resource "azurerm_public_ip" "lb" {
  name                = "pip-loadbalancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = "Learning"
    Project     = "Terraform-Assignment"
    Student     = var.student_name
  }
}

# Load Balancer
resource "azurerm_lb" "main" {
  name                = "lb-ha-webapp"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = azurerm_public_ip.lb.id
  }

  tags = {
    Environment = "Learning"
    Project     = "Terraform-Assignment"
    Student     = var.student_name
  }
}

# Backend Address Pool
# This is the pool of VMs that can recieve traffic
resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "backend-pool"
}

# Associate VM1 NIC with Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "vm1" {
  network_interface_id    = azurerm_network_interface.vm1.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

# Associate VM2 NIC with Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "vm2" {
  network_interface_id    = azurerm_network_interface.vm2.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}