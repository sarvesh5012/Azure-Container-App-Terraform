locals {
  config = yamldecode(file("variables.yml"))

  namespace   = local.config["namespace"]
  environment = local.config["environment"]
  location    = local.config["location"]



  # VPC
  vnet_config      = local.config["vnet"]
  vnet_cidr_block  = local.vnet_config["vnet_cidr_block"]
  public_subnets   = local.vnet_config["public_subnets"]
  private_subnets  = local.vnet_config["private_subnets"]
  database_subnets = local.vnet_config["database_subnets"]

  # Tags
  common_tags = local.config["common_tags"]
}