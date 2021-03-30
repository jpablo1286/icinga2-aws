output "instance" {
  value = aws_instance.icinga2_node[*]
}
output "instance_port" {
  value = aws_lb_target_group_attachment.icinga2_tg_attach[0].port
}