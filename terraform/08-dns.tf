module "dynamic_dns_whoi_it" {
  source = "./modules/dynamic-dns"

  domain_name                     = "whoi-it.whoi.edu"
  cloudendure_source_machine_name = "fooey"
  ip_address_primary              = "128.128.216.62"
  health_check_port               = 80
  health_check_resource_path      = "/wp-load.php"
  lambda_cloudendure_launch_arn   = aws_lambda_function.lambda_cloudendure_launch.arn
  common_tags                     = local.common_tags
}
