terraform {
  required_version = ">= 0.11"
}

resource "aws_iam_role" "app-svc" {
  name = "${var.name}-ecs-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
	{
	  "Sid": "",
	  "Effect": "Allow",
	  "Principal": {
		"Service": "ecs.amazonaws.com"
	  },
	  "Action": "sts:AssumeRole"
	}
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "app-svc" {
  role       = "${aws_iam_role.svc.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_cloudwatch_log_group" "app-svc" {
  count = "${length(var.log_groups)}"
  name  = "${element(var.log_groups, count.index)}"
  tags  = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

resource "aws_ecs_service" "app-svc" {
  name            = "${var.name}"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.test-app.arn}"
  desired_count   = "${var.desired_count}"
  iam_role        = "${aws_iam_role.app-svc.arn}"

  deployment_maximum_percent         = "${var.deployment_maximum_percent}"
  deployment_minimum_healthy_percent = "${var.deployment_minimum_healthy_percent}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.front_end.arn}"
    container_name   = "${var.container_name}"
    container_port   = "${var.container_port}"
  }
}