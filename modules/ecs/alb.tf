module "alb" {
  source = "../alb"

  environment       = var.environment
  alb_name          = "${var.environment}-${var.cluster}"
  vpc_id            = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
}
