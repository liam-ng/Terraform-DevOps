  # sNet NSG for uat spoke
    # Create Network Security Group and rule (nsg-snet-uat-web-001)
      resource "azurerm_network_security_group" "nsg_snet_uat_web_001" {
          provider            = azurerm.uat
          name                = "nsg-snet-uat-web-001"
          location            = azurerm_resource_group.spoke_uat_NetRG.location
          resource_group_name = azurerm_resource_group.spoke_uat_NetRG.name

          security_rule {
              name                       = "obd-all-snet-uat-app"
              priority                   = 1100
              destination_address_prefix = "192.169.1.0/24"
              # Deny all traffic to other subnet
              direction                  = "Outbound"
              access                     = "Deny"
              protocol                   = "*"
              source_port_range          = "*"
              destination_port_range     = "*"
              source_address_prefix      = "*"
          }

          security_rule {
              name                       = "obd-all-snet-uat-db"
              priority                   = 1110
              destination_address_prefix = "192.169.2.0/24"
              # Deny all traffic to other subnet
              direction                  = "Outbound"
              access                     = "Deny"
              protocol                   = "*" 
              source_port_range          = "*"
              destination_port_range     = "*"
              source_address_prefix      = "*"
          }

          security_rule {
              name                       = "iba-remote-liam"
              priority                   = 1000
              source_address_prefix      = "119.236.127.51"
              destination_port_ranges     = ["3389","22"]
              # Deny all traffic to other subnet
              direction                  = "Inbound"
              access                     = "Allow"
              protocol                   = "TCP"
              source_port_range         = "*"
              destination_address_prefix = "*"
          }

          tags = var.uatTags
      }
    # Create Network Security Group and rule (nsg-snet-uat-app-001)
      resource "azurerm_network_security_group" "nsg_snet_uat_app_001" {
          provider            = azurerm.uat
          name                = "nsg-snet-uat-app-001"
          location            = azurerm_resource_group.spoke_uat_NetRG.location
          resource_group_name = azurerm_resource_group.spoke_uat_NetRG.name

          security_rule {
              name                       = "obd-all-snet-uat-web"
              priority                   = 1100
              destination_address_prefix = "192.169.0.0/24"
              # Deny all traffic to other subnet
              direction                  = "Outbound"
              access                     = "Deny"
              protocol                   = "*"
              source_port_range          = "*"
              destination_port_range     = "*"
              source_address_prefix      = "*"
          }

          security_rule {
              name                       = "obd-all-snet-uat-db"
              priority                   = 1110
              destination_address_prefix = "192.169.2.0/24"
              # Deny all traffic to other subnet
              direction                  = "Outbound"
              access                     = "Deny"
              protocol                   = "*" 
              source_port_range          = "*"
              destination_port_range     = "*"
              source_address_prefix      = "*"
          }

          security_rule {
              name                       = "iba-remote-liam"
              priority                   = 1000
              source_address_prefix      = "119.236.127.51"
              destination_port_ranges    = ["3389","22"]
              # Deny all traffic to other subnet
              direction                  = "Inbound"
              access                     = "Allow"
              protocol                   = "TCP"
              source_port_range          = "*"
              destination_address_prefix = "*"
          }

          tags = var.uatTags
      }
    # Create Network Security Group and rule (nsg-snet-uat-db-001)
      resource "azurerm_network_security_group" "nsg_snet_uat_db_001" {
          provider            = azurerm.uat
          name                = "nsg-snet-uat-db-001"
          location            = azurerm_resource_group.spoke_uat_NetRG.location
          resource_group_name = azurerm_resource_group.spoke_uat_NetRG.name

          security_rule {
              name                       = "obd-all-snet-uat-web"
              priority                   = 1100
              destination_address_prefix = "192.169.0.0/24"
              # Deny all traffic to other subnet
              direction                  = "Outbound"
              access                     = "Deny"
              protocol                   = "*"
              source_port_range          = "*"
              destination_port_range     = "*"
              source_address_prefix      = "*"
          }

          security_rule {
              name                       = "obd-all-snet-uat-app"
              priority                   = 1110
              destination_address_prefix = "192.169.1.0/24"
              # Deny all traffic to other subnet
              direction                  = "Outbound"
              access                     = "Deny"
              protocol                   = "*" 
              source_port_range          = "*"
              destination_port_range     = "*"
              source_address_prefix      = "*"
          }

          security_rule {
              name                       = "iba-remote-liam"
              priority                   = 1000
              source_address_prefix      = "119.236.127.51"
              destination_port_ranges    = ["3389","22"]
              # Deny all traffic to other subnet
              direction                  = "Inbound"
              access                     = "Allow"
              protocol                   = "TCP"
              source_port_range          = "*"
              destination_address_prefix = "*"
          }

          tags = var.uatTags
      }

      # Connect the security group to the network interface
        resource "azurerm_subnet_network_security_group_association" "add_nsg_snet_uat_web_001" {
            provider                  = azurerm.uat
            subnet_id                 = azurerm_subnet.uat_web.id
            network_security_group_id = azurerm_network_security_group.nsg_snet_uat_web_001.id
        }
        resource "azurerm_subnet_network_security_group_association" "add_nsg_snet_uat_app_001" {
            provider                  = azurerm.uat
            subnet_id                 = azurerm_subnet.uat_app.id
            network_security_group_id = azurerm_network_security_group.nsg_snet_uat_app_001.id
        }
        resource "azurerm_subnet_network_security_group_association" "add_nsg_snet_uat_db_001" {
            provider                  = azurerm.uat
            subnet_id                 = azurerm_subnet.uat_db.id
            network_security_group_id = azurerm_network_security_group.nsg_snet_uat_db_001.id
        }