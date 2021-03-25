resource "aws_cloudwatch_metric_alarm" "ecs_high_cpu" {
  alarm_name          = "${var.environment}-${var.cluster}-ecs-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"

  dimensions {
    ClusterName = "${aws_ecs_cluster.cluster.name}"
  }

  alarm_description = "This metric monitors ECS Instance cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.ecs_scaling.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "ecs_low_cpu" {
  alarm_name          = "${var.environment}-${var.cluster}-ecs-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "360"
  statistic           = "Average"
  threshold           = "20"

  dimensions {
    ClusterName = "${aws_ecs_cluster.cluster.name}"
  }

  alarm_description = "This metric monitors ECS Instance cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.ecs_scaling.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "ecs-alert_High-MemReservation" {
  alarm_name          = "${var.environment}-${var.cluster}-ECS-High_MemResv"
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
    ClusterName = "${aws_ecs_cluster.cluster.name}"
  }

  actions_enabled = true
  insufficient_data_actions = []
  alarm_actions = ["${var.sns_topic_cloudwatch_alarm_arn}"]
}

resource "aws_cloudwatch_metric_alarm" "ecs-alert_Low-MemReservation" {
  alarm_name          = "${var.env}-${var.cluster}-ECS-Low_MemResv"
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
    ClusterName = "${aws_ecs_cluster.cluster.name}"
  }

  actions_enabled = true
  alarm_actions = ["${aws_autoscaling_policy.ecs_scaling.arn}"]
}

