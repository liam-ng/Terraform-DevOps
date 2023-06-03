variable "defaultLocation" {
        default         = "eastasia"
        description     = "Default Location"
}
variable "hubTags" {
 type = object({
   Environment = string
 })
 description = "Tags for the resources under Shared Resource Hub Environment"
 default = {
   Environment = "Shared Resource Hub"
 }
}
variable "uatTags" {
 type = object({
   Environment = string
 })
 description = "Tags for the resources under UAT Environment"
 default = {
   Environment = "UAT"
 }
}