module "static_site_workzone" {
  source = "./modules/static-s3-site"

  static_site_domain_name = "workzone.whoi.edu"
  common_tags             = local.common_tags
}
