resource "azurerm_resource_group" "main" {

  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Learning"
    Project = "Lab-Report-2-Terraform"
    Student = var.student_name
  }
}

