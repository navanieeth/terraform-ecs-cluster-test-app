output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "app_alb_target_group" {
  value = aws_alb_target_group.front_end.arn
}
