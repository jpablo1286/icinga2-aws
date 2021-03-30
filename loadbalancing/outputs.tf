output "lb_target_group_arn" {
  value = aws_lb_target_group.icinga2_tg.arn
}
output "lb_endpoint" {
  value = aws_lb.icinga2_lb.dns_name
}