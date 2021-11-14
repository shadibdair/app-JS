# Author Shadi Badir


# Define Local Values in Terraform
locals {
  owners = var.author
  environment = var.environment
  resource_name_prefix = "${var.author}-${var.environment}"
  common_tags = {
    owners = local.owners
    environment = local.environment
  }
} 


# Resource: Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name = "${local.resource_name_prefix}-${var.resource_group_name}"
  location = var.resource_group_location
  tags = local.common_tags
}

#----------------------------------------------

