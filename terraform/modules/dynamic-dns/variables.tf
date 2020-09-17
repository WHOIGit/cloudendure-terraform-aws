# Route 53 variables
variable "domain_name" {
  description = "Domain name of the Route53 zone"
  type        = string
}

variable "ip_address_primary" {
  description = "IP address of the primary site host for failover DNS"
  type        = string
}

variable "health_check_domain_name" {
  description = "Domain name to use for primary health check"
  type        = string
}

variable "health_check_port" {
  description = "Port for Route53 Health Check"
  type        = number
  default     = 80
}

variable "health_check_resource_path" {
  description = "Resource path for Route53 Health Check"
  type        = string
  default     = "/"
}

# Lambda Variables
variable "lambda_cloudendure_launch_name" {
  description = "Name for the cloudendure-launch-target-machine Lambda"
  type        = string
  default     = "cloudendure_launch_target_machine"
}

variable "lambda_cloudendure_launch_arn" {
  description = "AWS ARN for the cloudendure-launch-target-machine Lambda"
  type        = string
}

variable "cloudendure_source_machine_name" {
  description = "Machine name of the source server in CloudEndure. This may differ from DNS"
  type        = string
}

variable "common_tags" {
  description = "Common tags from project"
}
