output "lb-listener-arn" {
  value = aws_lb_listener.http.arn
}

output "lb-target-group-name" {
  value = aws_lb_target_group.lb-tg.name
}
