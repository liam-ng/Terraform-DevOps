
# Hub & Spoke Network
  # Network Resource Group
    resource "azurerm_resource_group" "hubNetRG" {
      name     = "rg-srh-liam-network-001"
      location = var.defaultLocation
      tags     = var.hubTags
    }

  # Virtual Network & Subnet
    resource "azurerm_virtual_network" "hub_vNet" {
      name                = "vnet-srh-001"
      resource_group_name = azurerm_resource_group.hubNetRG.name
      location            = azurerm_resource_group.hubNetRG.location
      address_space       = ["10.69.0.0/16"]
      #dns_servers         = ["10.69.0.4", "10.69.0.5"]
      tags     = var.hubTags
    }

    # Subnets of Hub vNet 
      resource "azurerm_subnet" "srh_adds" {
        name                 = "snet-srh-adds-001"
        resource_group_name  = azurerm_resource_group.hubNetRG.name
        virtual_network_name = azurerm_virtual_network.hub_vNet.name
        address_prefixes     = ["10.69.0.0/24"]
      }
      resource "azurerm_subnet" "srh_bastion" {
        name                 = "AzureBastionSubnet"
        resource_group_name  = azurerm_resource_group.hubNetRG.name
        virtual_network_name = azurerm_virtual_network.hub_vNet.name
        address_prefixes     = ["10.69.1.0/24"]
      }
      resource "azurerm_subnet" "srh_gw" {
        name                 = "GatewaySubnet"
        resource_group_name  = azurerm_resource_group.hubNetRG.name
        virtual_network_name = azurerm_virtual_network.hub_vNet.name
        address_prefixes     = ["10.69.2.0/24"]
      }
      resource "azurerm_subnet" "srh_afw" {
        name                 = "AzureFirewallSubnet"
        resource_group_name  = azurerm_resource_group.hubNetRG.name
        virtual_network_name = azurerm_virtual_network.hub_vNet.name
        address_prefixes     = ["10.69.3.0/24"]
      }

    resource "azurerm_virtual_network" "spoke_uat_vNet" {
      provider            = azurerm.uat
      name                = "vnet-uat-001"
      resource_group_name = azurerm_resource_group.spoke_uat_NetRG.name
      location            = azurerm_resource_group.spoke_uat_NetRG.location
      address_space       = ["192.169.0.0/16"]
      tags     = var.uatTags
    }