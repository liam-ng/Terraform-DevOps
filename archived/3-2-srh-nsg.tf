  # sNet NSG for SRH
    # Create Network Security Group and rule (nsg-snet-srh-adds-001)
      resource "azurerm_network_security_group" "nsg_snet_srh_adds_001" {
          name                = "nsg-${azurerm_subnet.srh_adds.name}"
          location            = azurerm_resource_group.hubNetRG.location
          resource_group_name = azurerm_resource_group.hubNetRG.name

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

          tags = var.hubTags
      }
      # Connect the security group to the network interface
        resource "azurerm_subnet_network_security_group_association" "add_nsg_snet_srh_adds_001" {
            subnet_id                 = azurerm_subnet.srh_adds.id
            network_security_group_id = azurerm_network_security_group.nsg_snet_srh_adds_001.id
        }
