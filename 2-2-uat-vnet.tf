
# Hub & Spoke Network
  # Network Resource Group

    resource "azurerm_resource_group" "spoke_uat_NetRG" {
      provider = azurerm.uat
      name     = "rg-uat-liam-network-001"
      location = var.defaultLocation
      tags     = var.uatTags
    }

  # Virtual Network & Subnet
    resource "azurerm_virtual_network" "spoke_uat_vNet" {
      provider            = azurerm.uat
      name                = "vnet-uat-001"
      resource_group_name = azurerm_resource_group.spoke_uat_NetRG.name
      location            = azurerm_resource_group.spoke_uat_NetRG.location
      address_space       = ["192.169.0.0/16"]
      tags     = var.uatTags
    }

    # Subnets of spoke uat vNet 
      resource "azurerm_subnet" "uat_web" {
        provider             = azurerm.uat
        name                 = "snet-uat-web-001"
        resource_group_name  = azurerm_resource_group.spoke_uat_NetRG.name
        virtual_network_name = azurerm_virtual_network.spoke_uat_vNet.name
        address_prefixes     = ["192.169.0.0/24"]
      }
      resource "azurerm_subnet" "uat_app" {
        provider             = azurerm.uat
        name                 = "snet-uat-app-001"
        resource_group_name  = azurerm_resource_group.spoke_uat_NetRG.name
        virtual_network_name = azurerm_virtual_network.spoke_uat_vNet.name
        address_prefixes     = ["192.169.1.0/24"]
      }
      resource "azurerm_subnet" "uat_db" {
        provider             = azurerm.uat
        name                 = "snet-uat-db-001"
        resource_group_name  = azurerm_resource_group.spoke_uat_NetRG.name
        virtual_network_name = azurerm_virtual_network.spoke_uat_vNet.name
        address_prefixes     = ["192.169.2.0/24"]
      }