# Hub Components
  # Shared Resource Group
    resource "azurerm_resource_group" "hubSharedRG" {
      name     = "rg-srh-liam-shared-001"
      location = var.defaultLocation
      tags     = var.hubTags
    }

    resource "azurerm_resource_group" "hubCommonRG" {
      name     = "rg-srh-liam-common-001"
      location = var.defaultLocation
      tags     = var.hubTags
    }

  # Virtual machine - Ubuntu 20.04-LTS at Zone 2
    # Create public IPs for vmrelay01
      resource "azurerm_public_ip" "pip01_vmrelay01" {
          name                         = "pip01-vmrelay01"
          location                     = azurerm_resource_group.hubSharedRG.location
          resource_group_name          = azurerm_resource_group.hubSharedRG.name
          sku                          = "Standard"
          allocation_method            = "Static"

          tags = var.hubTags
      }


    # Create network interface
      resource "azurerm_network_interface" "nic01_vmrelay01" {
          name                      = "nic01-vmrelay01"
          location                  = azurerm_resource_group.hubSharedRG.location
          resource_group_name       = azurerm_resource_group.hubSharedRG.name

          ip_configuration {
              name                          = "myNicConfiguration"
              subnet_id                     = azurerm_subnet.srh_adds.id
              private_ip_address_allocation = "Static"
              private_ip_address            = "10.69.0.4"
              public_ip_address_id          = azurerm_public_ip.pip01_vmrelay01.id
          }

          tags =  var.hubTags
      }

    # Generate random text for a unique storage account name
      /*
          resource "random_id" "randomId" {
          keepers = {
              # Generate a new ID only when a new resource group is defined
              resource_group = azurerm_resource_group.spoke_uat_NetRG.name
          }

          byte_length = 8
      }
      ${random_id.randomId.hex}
      */

    # Create storage account for boot diagnostics
      resource "azurerm_storage_account" "sadiagliamsrh001" {
          name                        = "sadiagliamsrh001" #must be less than 24 char
          resource_group_name         = azurerm_resource_group.hubCommonRG.name
          location                    = azurerm_resource_group.hubCommonRG.location
          account_tier                = "Standard"
          account_replication_type    = "LRS"

          tags = var.hubTags
      }

    # Create (and display) an SSH key
      resource "tls_private_key" "vmrelay01_ssh" {
        algorithm = "RSA"
        rsa_bits = 4096
      }
      output "tls_private_key" { # Run after apply > terraform output -raw tls_private_key
          value = tls_private_key.vmrelay01_ssh.private_key_pem 
          sensitive = true
      }

    # Create virtual machine
      resource "azurerm_linux_virtual_machine" "vmrelay01" {
          name                  = "vmrelay01"
          location              = azurerm_resource_group.hubSharedRG.location
          resource_group_name   = azurerm_resource_group.hubSharedRG.name
          network_interface_ids = [azurerm_network_interface.nic01_vmrelay01.id]
          size                  = "Standard_B2s"
          zone                  = 2

          os_disk {
              name              = "disk01-vmrelay01"
              caching           = "ReadWrite"
              storage_account_type = "StandardSSD_LRS"
          }

          source_image_reference {
              publisher = "canonical"
              offer     = "0001-com-ubuntu-server-focal"
              sku       = "20_04-lts-gen2"
              version   = "latest"
          }

          computer_name  = "vmrelay01" #must be less than 15 char
          admin_username = "azureadmin"
          disable_password_authentication = true

          admin_ssh_key {
              username       = "azureadmin"
              public_key     = tls_private_key.vmrelay01_ssh.public_key_openssh
          }

          boot_diagnostics {
              storage_account_uri = azurerm_storage_account.sadiagliamsrh001.primary_blob_endpoint
          }

          tags =  var.hubTags
      }

  # Create Azure Firewall
    resource "azurerm_public_ip" "pip01_afw_srh_liam_001" {
    name                = "pip01-afw-srh-liam-001"
    location            = azurerm_resource_group.hubNetRG.location
    resource_group_name = azurerm_resource_group.hubNetRG.name
    allocation_method   = "Static"
    sku                 = "basic"
  }
      resource "azurerm_firewall" "afw_srh_liam_001" {
    name                = "afw-srh-liam-001"
    location            = azurerm_resource_group.hubNetRG.location
    resource_group_name = azurerm_resource_group.hubNetRG.name

    ip_configuration {
      name                 = "configuration"
      subnet_id            = azurerm_subnet.srh_afw.id
      public_ip_address_id = azurerm_public_ip.pip01_afw_srh_liam_001.id
    }
  }

  # Create Bastion
    resource "azurerm_public_ip" "pip01_bas_srh_liam_001" {
    name                = "pip01-bas-srh-liam-001"
    location            = azurerm_resource_group.hubNetRG.location
    resource_group_name = azurerm_resource_group.hubNetRG.name
    allocation_method   = "Static"
    sku                 = "Basic"
  }

  resource "azurerm_bastion_host" "bas_srh_liam_001" {
    name                = "bas-srh-liam-001"
    location            = azurerm_resource_group.hubNetRG.location
    resource_group_name = azurerm_resource_group.hubSharedRG.name

    ip_configuration {
      name                 = "configuration"
      subnet_id            = azurerm_subnet.srh_bastion.id
      public_ip_address_id = azurerm_public_ip.pip01_bas_srh_liam_001.id
    }
  }

  # Create VPN
