
# Keeping ONLY the Resource Group here (repository was refactored midway through the project for clearer separation of conserns)


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
