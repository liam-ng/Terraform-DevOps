# Azure Governance
  # Enable Log Analytics (formally Operational Insights) Solution 
    # Create common Log Analytics Workspace for SRH
      resource "azurerm_log_analytics_workspace" "log_srh_liam_shared_001" {
      name                = "log-srh-liam-shared-001"
      location            = azurerm_resource_group.hubCommonRG.location
      resource_group_name = azurerm_resource_group.hubCommonRG.name
      sku                 = "PerGB2018" # "PerGB2018" for Prod; "Free" for test
      retention_in_days   = 30 # range between 30 and 730 for "PerGB2018" SKU; 7 for "Free" SKU
      tags                = var.hubTags
    }

    # Enabling Log Analytics agent & Dependency agent for VM (vmrelay01)
      resource "azurerm_virtual_machine_extension" "laa_vmrelay01" {
      name                       = "LAAExtension"
      virtual_machine_id         = azurerm_linux_virtual_machine.vmrelay01.id
      publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
      type                       = "OmsAgentForLinux"
      type_handler_version       = "1.12"
      auto_upgrade_minor_version = true

      settings = <<SETTINGS
        {
          "workspaceId" : "${azurerm_log_analytics_workspace.log_srh_liam_shared_001.workspace_id}"
        }
      SETTINGS

      protected_settings = <<PROTECTED_SETTINGS
        {
          "workspaceKey" : "${azurerm_log_analytics_workspace.log_srh_liam_shared_001.primary_shared_key}"
        }
      PROTECTED_SETTINGS
    }
      
      resource "azurerm_virtual_machine_extension" "da_vmrelay01" {
      name                       = "DAExtension"
      virtual_machine_id         =  azurerm_linux_virtual_machine.vmrelay01.id
      publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
      type                       = "DependencyAgentLinux"
      type_handler_version       = "9.5"
      auto_upgrade_minor_version = true
    }

  # Create common Automation Account for SRH
    resource "azurerm_automation_account" "aa_srh_liam_shared_001" {
    name                = "aa-srh-liam-shared-001"
    location            = azurerm_resource_group.hubCommonRG.location
    resource_group_name = azurerm_resource_group.hubCommonRG.name
    sku_name            = "Basic"
    tags                = var.hubTags
  }
  