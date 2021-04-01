resource "aws_lb" "icinga2_lb" {
  name = "icinga2-lb"
  subnets = var.icinga_subnets
  security_groups = [ var.icinga_sg ]
  idle_timeout = 400
}

resource "aws_lb_target_group" "icinga2_tg" {
  name = "icinga2-${substr(uuid(),0,3)}"
  port = var.tg_port
  protocol = var.tg_protocol
  vpc_id = var.vpc_id
  lifecycle {
    ignore_changes = [name]
    create_before_destroy = true
  }
  health_check {
    healthy_threshold = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_unhealthy_threshold
    timeout = var.lb_timeout
    interval = var.lb_interval
  }
}

resource "aws_lb_listener" "icinga2_listener" {
  load_balancer_arn = aws_lb.icinga2_lb.arn
  port = var.listener_port
  protocol = var.listener_protocol
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.icinga2_tg.arn
  }
}