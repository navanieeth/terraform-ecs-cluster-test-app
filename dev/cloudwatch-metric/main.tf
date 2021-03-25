resource "aws_cloudwatch_metric_alarm" "ecs_high_cpu" {
  alarm_name          = "${var.env}-${var.ecs_cluster_name}-ecs-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }

  alarm_description = "This metric monitors ECS Instance cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.ecs_scaling.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "ecs_low_cpu" {
  alarm_name          = "${var.env}-${var.ecs_cluster_name}-ecs-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "360"
  statistic           = "Average"
  threshold           = "20"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
  }

  alarm_description = "This metric monitors ECS Instance cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.ecs_scaling.arn}"]
}

data "terraform_remote_state" "sns" {
  backend = "s3"

  config = {
    bucket = "terraform-714553166291-eu-west-1-management"
    key    = "sns/sns.tfstate"
    region = "eu-west-1"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs-alert_High-MemReservation" {
  alarm_name = "${var.company}/${var.project}-ECS-High_MemResv"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  period = "60"
  evaluation_periods = "1"
  datapoints_to_alarm = 1

  statistic = "Average"
  threshold = "80"
  alarm_description = ""

  metric_name = "MemoryReservation"
  namespace = "AWS/ECS"
  dimensions = {
    ClusterName = "${aws_ecs_cluster.container.name}"
  }

  actions_enabled = true
  insufficient_data_actions = []
  alarm_actions = [
    "${var.sns_topic_cloudwatch_alarm_arn}",
    "${aws_autoscaling_policy.ecs_scaling.arn}",
  ]
  ok_actions  = [data.terraform_remote_state.sns.outputs.sns-WAS-ALB-UnhealthyHosts_Alarm, "arn:aws:sns:eu-west-1:714553166291:OpsGenie"]
}

resource "aws_cloudwatch_metric_alarm" "ecs-alert_Low-MemReservation" {
  alarm_name = "${var.company}/${var.project}-ECS-Low_MemResv"
  comparison_operator = "LessThanThreshold"

  period = "300"
  evaluation_periods = "1"
  datapoints_to_alarm = 1

  statistic = "Average"
  threshold = "40"
  alarm_description = ""

  metric_name = "MemoryReservation"
  namespace = "AWS/ECS"
  dimensions = {
    ClusterName = "${aws_ecs_cluster.container.name}"
  }

  actions_enabled = true
  insufficient_data_actions = []
  alarm_actions = [
    "${data.terraform_remote_state.sns.outputs.sns-WAS-ALB-UnhealthyHosts_Alarm, "arn:aws:sns:eu-west-1:714553166291:OpsGenie"}",
    "${aws_autoscaling_policy.ecs_scaling.arn}",
  ]
  ok_actions          = [data.terraform_remote_state.sns.outputs.sns-WAS-ALB-UnhealthyHosts_Alarm, "arn:aws:sns:eu-west-1:714553166291:OpsGenie"]
}

# Cloudwatch monitoring alarm for Unhealthy Hosts of Target Group
resource "aws_cloudwatch_metric_alarm" "was-alb-9090" {
  alarm_name          = "TG-WAS-ALB-9090: UnHealthyHostCount Alert"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  alarm_description   = "Number of nodes unhealthy in Target Group"
  actions_enabled     = "true"
  alarm_actions       = [data.terraform_remote_state.sns.outputs.sns-WAS-ALB-UnhealthyHosts_Alarm, "arn:aws:sns:eu-west-1:714553166291:OpsGenie"]
  ok_actions          = [data.terraform_remote_state.sns.outputs.sns-WAS-ALB-UnhealthyHosts_Alarm, "arn:aws:sns:eu-west-1:714553166291:OpsGenie"]
  insufficient_data_actions = [data.terraform_remote_state.sns.outputs.sns-WAS-ALB-UnhealthyHosts_Alarm, "arn:aws:sns:eu-west-1:714553166291:OpsGenie"]
  dimensions = {
    TargetGroup  = aws_lb_target_group.prd_was_http_9090.arn_suffix
    LoadBalancer = aws_lb.somswas_prd_alb.arn_suffix
  }
}

