# Author Shadi Badir


# Resource: Azure Linux Virtual Machine
resource "azurerm_postgresql_server" "db_postgress" {
  name = "dbpostgres-staging"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  administrator_login          = "postgres"
  administrator_login_password = var.postgres_password
  sku_name   = "B_Gen5_1"
  version    = "11"
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  #auto_grow_enabled            = true
  public_network_access_enabled    = true
  ssl_enforcement_enabled           = false
}



# Resource-3: Azure MySQL Firewall Rule - Allow access from Bastion Host Public IP
resource "azurerm_postgresql_firewall_rule" "postgres_fw_rule" {
  name                = "allow-access-publicip"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_postgresql_server.db_postgress.name
  start_ip_address    = azurerm_public_ip.web_lbpublicip.ip_address
  end_ip_address      = azurerm_public_ip.web_lbpublicip.ip_address
}


#-----------------------------------------------------------

# db-subnet-nsg-nic

# Resource-1: Create DBTier Subnet
resource "azurerm_subnet" "dbsubnet" {
  name                 = "${azurerm_virtual_network.vnet.name}-${var.db_subnet_name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.db_subnet_address  
}

# Resource-2: Create Network Security Group (NSG)
resource "azurerm_network_security_group" "db_subnet_nsg" {
  name                = "${azurerm_subnet.dbsubnet.name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Resource-3: Associate NSG and Subnet
resource "azurerm_subnet_network_security_group_association" "db_subnet_nsg_associate" {
  depends_on = [ azurerm_network_security_rule.db_nsg_rule_inbound]  
  subnet_id                 = azurerm_subnet.dbsubnet.id
  network_security_group_id = azurerm_network_security_group.db_subnet_nsg.id
}

# Resource-4: Create NSG Rules
## Locals Block for Security Rules
locals {
  db_inbound_ports_map = {
    # If the key starts with a number, you must use the colon syntax ":" instead of "="
    "3000" : "5432",
    "3010" : "22"
  } 
}

## NSG Inbound Rule for DBTier Subnets
resource "azurerm_network_security_rule" "db_nsg_rule_inbound" {
  for_each = local.db_inbound_ports_map
  name                        = "Rule-Port-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value 
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.db_subnet_nsg.name
}

# ## NSG Outbound Rule for DBTier Subnets
# resource "azurerm_network_security_rule" "db_nsg_rule_outbound" {
#   for_each = local.db_inbound_ports_map
#   name                        = "DenyInternet"
#   priority                    = "1000"
#   direction                   = "Outbound"
#   access                      = "Deny"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*" 
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.rg.name
#   network_security_group_name = azurerm_network_security_group.db_subnet_nsg.name
# }

#--------------------------------------------------------

# Resource-2: Create Network Interface
resource "azurerm_network_interface" "db_postgress_nic" {
  name                = "${local.resource_name_prefix}-db_postgress_nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "db-postgress-ip-1"
    subnet_id                     = azurerm_subnet.dbsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

