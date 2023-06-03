
  # vNet peering
    resource "azurerm_virtual_network_peering" "vnpeer_hub_toSpoke" {
      name                         = "vnpeer-${azurerm_virtual_network.hub_vNet.name}-${azurerm_virtual_network.spoke_uat_vNet.name}"
      resource_group_name          = azurerm_resource_group.hubNetRG.name
      virtual_network_name         = azurerm_virtual_network.hub_vNet.name
      remote_virtual_network_id    = azurerm_virtual_network.spoke_uat_vNet.id
      allow_virtual_network_access = true
      allow_forwarded_traffic      = false
      allow_gateway_transit        = false
    }

    resource "azurerm_virtual_network_peering" "vnpeer_spoke_toHub" {
      provider                     = azurerm.uat
      name                         = "vnpeer-${azurerm_virtual_network.spoke_uat_vNet.name}-${azurerm_virtual_network.hub_vNet.name}"
      resource_group_name          = azurerm_resource_group.spoke_uat_NetRG.name
      virtual_network_name         = azurerm_virtual_network.spoke_uat_vNet.name
      remote_virtual_network_id    = azurerm_virtual_network.hub_vNet.id
      allow_virtual_network_access = true
      allow_forwarded_traffic      = false
      allow_gateway_transit        = false
      use_remote_gateways          = false
    }
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