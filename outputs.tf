output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "vnet_name" {
  description = "Name of the created virtual network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_id" {
  description = "ID of the created virtual network"
  value       = azurerm_virtual_network.main.id
}


# ===========================================================
# SUBNET OUTPUTS
# ===========================================================

output "public_subnet_1_id" {
  description = "ID of public subnet in Availability Zone 1"
  value       = azurerm_subnet.public_1.id
}

output "public_subnet_1_cidr" {
  description = "CIDR block of public subnet 1"
  value       = azurerm_subnet.public_1.address_prefixes[0]
}

output "public_subnet_2_id" {
  description = "ID of public subnet in Availability Zone 2"
  value       = azurerm_subnet.public_2.id
}

output "public_subnet_2_cidr" {
  description = "CIDR block of public subnet 2"
  value       = azurerm_subnet.public_2.address_prefixes[0]
}

output "private_subnet_1_id" {
  description = "ID of private subnet in Availability Zone 1"
  value       = azurerm_subnet.private_1.id
}

output "private_subnet_2_id" {
  description = "ID of private subnet in Availability Zone 2"
  value       = azurerm_subnet.private_2.id
}