# Author Shadi Badir

# Terraform Block
terraform {
  # Specifies which versions of Terraform can be used with your configuration
  required_version = ">= 1.0.0"
  # Specifies of the provider required by the current module
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.0" 
    }
  }
}

# Provider Block
provider "azurerm" {
 features {}          
}
