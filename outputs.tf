output "resource_group_name" {
  description = "Name of the created resources group"
  value       = azurerm_resource_group.main.name
}

output "vnet_id" {
    description = "ID of the createdd virtual network"
    value = azure_virtual_network.main.id
}