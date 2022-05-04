# for the alb
module "main" {
  source                    = "./main"
  namespace                 = var.namespace
  env                       = var.env
  region                    = var.region
  vpc_tag                   = var.vpc_tag
  vpc_tags_isolated_subnets = var.vpc_tags_isolated_subnets
  vpc_tags_private_subnets  = var.vpc_tags_private_subnets
  vpc_tags_public_subnets   = var.vpc_tags_public_subnets
}