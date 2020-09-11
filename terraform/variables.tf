
variable "cloudendure_user_api_token" {
  description = "CloudEndure User API token"
  default = "7D76-748D-8993-198A-D1DD-227A-6C9C-C9A9-6033-66DF-E336-BDB4-D6B6-6F67-83FC-A178"
}

# Common tags for all resouces
locals {
  common_tags = {
    Project = "CloudEndure"
    Owner   = "AppDev"
    Client  = "IS"
  }
}
