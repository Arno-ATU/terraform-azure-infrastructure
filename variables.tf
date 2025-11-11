variable "resource_group_name" {
  description = "Name of resource grioup"
  type        = string
  default     = "Terraform_Lab2"
}

variable "location" {
  description = "Azure region where reources will be created and hosted"
  type        = string
  default     = "westeurope"
}

variable "student_name" {
    description = "Name/Student number for tagging"
    type = string
    default = "Arno-L00188491"
}