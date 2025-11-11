variable "resource_group_name" {
  description = "Name of resource grioup"
  type        = string
  default     = "Terraform_Lab2"
}

variable "location" {
  description = "Azure region where reources will be created and hosted"
  type        = string
  default     = "swedencentral"
}

variable "student_name" {
  description = "Name/Student number for tagging"
  type        = string
  default     = "Arno-L00188491"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}