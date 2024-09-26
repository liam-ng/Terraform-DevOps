terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.2"
    }
  }
}

variable "uat_tm"  {
  description = "list of traffic manager configurations"
  type = map(object({
    name                        = string
    routing_method              = string
    status                      = string
    ttl                         = number
    protocol                    = string
    port                        = number
    path                        = string
    expected_status_code_ranges = list(string)

    external_endpoints          = map(object({
      name                      = string
      target                    = string
      ratio                     = number
      priority                  = number
    }))
  }))
}

provider "azurerm" {
  resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
  subscription_id = "0a162681-a568-4dfe-acda-2c1f6996620a"
}
resource "azurerm_resource_group" "rg1" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "tm" {
  for_each = var.uat_tm

  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg1.name
  profile_status      = each.value.status
  traffic_routing_method = each.value.routing_method

  dns_config {
    relative_name = each.key
    ttl           = each.value.ttl
  }

  monitor_config {
    protocol = each.value.protocol
    port     = each.value.port
    path     = each.value.path
    expected_status_code_ranges = each.value.expected_status_code_ranges
  }
}

resource "azurerm_traffic_manager_external_endpoint" "endpoint" {
  depends_on = [ azurerm_traffic_manager_profile.tm ]
  for_each = tomap({
    for endpoint in local.tm_profiles : "${endpoint.profile_key}.${endpoint.endpoint_key}" => endpoint
    })
  
  name                = each.value.endpoint.name
  profile_id          = each.value.profile_id
  target              = each.value.endpoint.target
  weight              = each.value.endpoint.ratio
  priority            = each.value.endpoint.priority
}

locals {
  tm_profiles = flatten([
    for profile_key, profile in var.uat_tm : [
      for endpoint_key, endpoint in profile.external_endpoints : {
        profile_key = profile_key
        endpoint_key = endpoint_key
        profile_id = azurerm_traffic_manager_profile.tm[profile_key].id
        endpoint = endpoint
      }
    ]
  ])
}