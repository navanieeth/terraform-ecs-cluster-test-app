module "ecs_instances" {
  source = "../../modules/ecs"

  environment             = var.environment
  cluster                 = var.cluster
  private_subnet_ids      = module.network.private_subnet_ids
  aws_ami                 = var.ecs_aws_ami
  instance_type           = var.instance_type
  max_size                = var.max_size
  min_size                = var.min_size
  desired_capacity        = var.desired_capacity
  vpc_id                  = module.network.vpc_id
  iam_instance_profile_id = aws_iam_instance_profile.ecs.id
  key_name                = var.key_name
  load_balancers          = var.load_balancers
  custom_userdata         = var.custom_userdata
  cloudwatch_prefix       = var.cloudwatch_prefix
}

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster
}

resource "aws_ecs_task_definition" "test-app" {
  family                   = "test-app"
  container_definitions    = <<DEFINITION
    [{
      "name": "test-app",
      "image": "${format("%s:qa", var.my_ecr_arn)}",
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
        }
      ],
      "memory": 300,
      "networkMode": "awsvpc",
      "environment": [
        {
          "name": "db_username",
          "value": "admin"
        },
        {
          "name": "db_password",
          "value": "xxxxx"
        }
      ]
    }
  ]
  DEFINITION
  requires_compatibilities = ["EC2"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  task_role_arn            = var.ecs_role
  execution_role_arn       = var.ecs_role
}

module "ecs_service_app" {
  source = "../../modules/service"

  name                 = "ecs-alb-single-svc"
  alb_target_group_arn = "${module.alb.app_alb_target_group}"
  cluster              = "${aws_ecs_cluster.cluster.id}"
  container_name       = var.container_name
  container_port       = var.container_port
  log_groups           = ["ecs-alb-single-svc-app"]
  task_definition_arn  = "${aws_ecs_task_definition.test-app.arn}"
  task_desired_count   = var.desired_count
  tags = {
    Environment = "var.environment"
  }
}