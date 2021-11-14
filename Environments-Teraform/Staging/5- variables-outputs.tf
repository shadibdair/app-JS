# Author Shadi Badir


variable "postgres_password" {
  description = "Postgres administrator password"
  type        = string
  sensitive   = true
}

variable "web_password" {
  description = "Web administrator password"
  type        = string
  sensitive   = true
}


#-----------------------------------------------------------

# Virtual Network, Subnets and Subnet NSG's

## Virtual Network
variable "vnet_name" {
  description = "Virtual Network name"
  type = string
  default = "vnet"
}

variable "vnet_address_space" {
  description = "Virtual Network address_space"
  type = list(string)
  default = ["10.0.0.0/16"]
}

# Web Subnet Name
variable "web_subnet_name" {
  description = "Virtual Network Web Subnet Name"
  type = string
  default = "websubnet"
}
# Web Subnet Address Space
variable "web_subnet_address" {
  description = "Virtual Network Web Subnet Address Spaces"
  type = list(string)
  default = ["10.0.1.0/24"]
}

# Database Subnet Name
variable "db_subnet_name" {
  description = "Virtual Network Database Subnet Name"
  type = string
  default = "dbsubnet"
}
# Database Subnet Address Space
variable "db_subnet_address" {
  description = "Virtual Network Database Subnet Address Spaces"
  type = list(string)
  default = ["10.0.21.0/24"]
}

#-----------------------------------------------------

# Generic Input Variables
# Author
variable "author" {
  description = "This Infrastructure belongs to shadi badir"
  type = string
  default = "shadi"
}

# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type = string
  default = "staging"
}

# Azure Resource Group Name 
variable "resource_group_name" {
  description = "Resource Group Name"
  type = string
  default = "rg"  
}

# Azure Resources Location
variable "resource_group_location" {
  description = "Region in which Azure Resources to be created"
  type = string
  default = "westeurope"  
}

#-------------------------------------------------------

# Linux VM Input Variables Placeholder file.
# Web Linux VM Instance Count
variable "web_linuxvm_instance_count" {
  description = "Web Linux VM Instance Count"
  type = map(string)
  default = {
    "vm1" = "1022",
    "vm2" = "2022",
    "ansiblevm"  = "4022"
  }
}

# "ansiblevm"  = "4022"

#-------------------------------------------------------


# Virtual Network Outputs
## Virtual Network Name
output "virtual_network_name" {
  description = "Virtual Network Name"
  value = azurerm_virtual_network.vnet.name
}

## Virtual Network ID
output "virtual_network_id" {
  description = "Virtual Network ID"
  value = azurerm_virtual_network.vnet.id
}

## Subnet Name 
output "web_subnet_name" {
  description = "WebTier Subnet Name"
  value = azurerm_subnet.websubnet.name
}

## Subnet ID 
output "web_subnet_id" {
  description = "WebTier Subnet ID"
  value = azurerm_subnet.websubnet.id
}

# Network Security Outputs
## Web Subnet NSG Name 
output "web_subnet_nsg_name" {
  description = "WebTier Subnet NSG Name"
  value = azurerm_network_security_group.web_subnet_nsg.name
}

## Web Subnet NSG ID 
output "web_subnet_nsg_id" {
  description = "WebTier Subnet NSG ID"
  value = azurerm_network_security_group.web_subnet_nsg.id
}


#--------------------------------------------------------

# DB vm Output
# # Output Values
# output "postgresql_server_fqdn" {
#   description = "MySQL Server FQDN"
#   value = azurerm_postgress_server.db_postgress.fqdn
# }

#--------------------------------------------------------

# LB Public IP
output "web_lb_public_ip_address" {
  description = "Web Load Balancer Public Address"
  value = azurerm_public_ip.web_lbpublicip.ip_address
}

# Load Balancer ID
output "web_lb_id" {
  description = "Web Load Balancer ID"
  value = azurerm_lb.web_lb.id 
}

# Load Balancer Frontend IP Configuration Block
output "web_lb_frontend_ip_configuration" {
  description = "Web LB frontend_ip_configuration Block"
  value = [azurerm_lb.web_lb.frontend_ip_configuration]
}


#--------------------------------------------------------


# Output List - Single Input to for loop
output "web_linuxvm_private_ip_address_list" {
  description = "Web Linux Virtual Machine Private IP"
  # 1 Way 
  value = [for vm in azurerm_linux_virtual_machine.web_linuxvm: vm.private_ip_address]
}

# Output Map  - Single Input to for loop
output "web_linuxvm_private_ip_address_map" {
  description = "Web Linux Virtual Machine Private IP"
  # 2 Way
  value = {for vm in azurerm_linux_virtual_machine.web_linuxvm: vm.name => vm.private_ip_address}
}

# Terraform keys() function: keys takes a map and returns a list containing the keys from that map.
output "web_linuxvm_private_ip_address_keys_function" {
  description = "Web Linux Virtual Machine Private IP"
  value = keys({for vm in azurerm_linux_virtual_machine.web_linuxvm: vm.name => vm.private_ip_address})
}
# Terraform values() function: values takes a map and returns a list containing the values of the elements in that map.
output "web_linuxvm_private_ip_address_values_function" {
  description = "Web Linux Virtual Machine Private IP"
  value = values({for vm in azurerm_linux_virtual_machine.web_linuxvm: vm.name => vm.private_ip_address})
}

# Output List - Two Inputs to for loop (here vm is Iterator like "i")
output "web_linuxvm_network_interface_id_list" {
  description = "Web Linux VM Network Interface ID"
  value = [for vm, nic in azurerm_network_interface.web_linuxvm_nic: nic.id ]
}

# Output Map  - Two Inputs to for loop (here vm is Iterator like "i")
output "web_linuxvm_network_interface_id_map" {
  description = "Web Linux VM Network Interface ID"
  value = {for vm, nic in azurerm_network_interface.web_linuxvm_nic: vm => nic.id }
}

# Output Admin web VM's
output "web_Admin_vm" {
  description = "Web Linux VM Admin"
  value = [for vm in azurerm_linux_virtual_machine.web_linuxvm: vm.admin_username]
}

# Output Password web VM's
output "web_Password_vm" {
  description = "Web Linux VM Password"
  sensitive   = true
  value = [for vm in azurerm_linux_virtual_machine.web_linuxvm: vm.admin_password]
}



