#Hello
# Default subscription CTU-QA-PROD
provider "azurerm" {
  subscription_id = "0b2fdcd2-0952-47d3-a3ff-5434b32f9b99"
  features{}
}

# uat subscription CTU-QA-UAT
provider "azurerm" {
  alias  = "uat"
  subscription_id = "b61e2d8d-eb30-47b2-87ef-5170cc59b0b7"
  features{}
}