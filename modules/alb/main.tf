resource "aws_alb_target_group" "front_end" {
  name                 = "${var.alb_name}-front_end"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    path     = var.health_check_path
    protocol = "HTTP"
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_alb" "alb" {
  name            = var.alb_name
  internal        = true
  subnets         = var.private_subnet_ids
  security_groups = ["${aws_security_group.alb.id}"]

  tags = {
    Environment = var.environment
  }
}

resource "aws_alb_listener" "front_end443" {
  load_balancer_arn = aws_alb.alb.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:iam::0000:server-certificate/test-cert"

  default_action {
    target_group_arn = aws_alb_target_group.front_end.id
    type             = "forward"
  }
}

resource "aws_lb_listener" "front_end80" {
  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_rule" "front_end443" {
  listener_arn = aws_lb_listener.front_end443.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }

  condition {
    host_header {
      values = ["example*.*"]
    }
  }
}

resource "aws_security_group" "alb" {
  name   = "${var.alb_name}_alb"
  vpc_id = var.vpc_id

  tags = {
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "http_from_anywhere" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = var.allow_cidr_block
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "https_from_anywhere" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = var.allow_cidr_block
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "outbound_internet_access" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

data "terraform_remote_state" "hostedzones" {
  backend = "s3"

  config = {
    bucket = "terraform-714553166291-eu-west-1-management"
    key    = "hostedzones/hostedzones.tfstate"
    region = "eu-west-1"
  }
}

resource "aws_route53_record" "app_alb_r53_record" {
  zone_id = data.terraform_remote_state.hostedzones.outputs.app_zone_id_0
  name    = "app-alb"
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}