resource "aws_lb" "env-01-elb-app" {
  drop_invalid_header_fields = "false"
  enable_deletion_protection = "false"
  enable_http2               = "true"
  idle_timeout               = "60"
  internal                   = "false"
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  name                       = "env-01-elb-app"
  security_groups            = [aws_security_group.env-01-lb-sg.id]

  subnet_mapping {
    subnet_id = aws_subnet.env-01-sub-a-pub.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.env-01-sub-b-pub.id
  }
}

resource "aws_lb_target_group" "env-01-elb-tgroup" {
  deregistration_delay = "300"

  health_check {
    enabled             = "true"
    healthy_threshold   = "2"
    interval            = "5"
    matcher             = "200"
    path                = "/api/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "3"
    unhealthy_threshold = "2"
  }

  load_balancing_algorithm_type = "round_robin"
  name                          = "env-01-elb-tgroup"
  port                          = "80"
  protocol                      = "HTTP"
  slow_start                    = "0"

  stickiness {
    cookie_duration = "86400" # NOTE: 24h
    enabled         = "false"
    type            = "lb_cookie"
  }

  target_type = "instance"
  vpc_id      = aws_vpc.env-01-vpc.id
}

resource "aws_lb_listener" "env-01-lb-listener-1" {
  default_action {
    target_group_arn = aws_lb_target_group.env-01-elb-tgroup.arn
    type             = "forward"
  }

  load_balancer_arn = aws_lb.env-01-elb-app.arn
  port              = "80"
  protocol          = "HTTP"
}

resource "aws_lb_target_group_attachment" "env-01-lb-tga-vm-1" {
  target_group_arn = aws_lb_target_group.env-01-elb-tgroup.arn
  target_id        = aws_instance.env-01-vm-swarm-1.id
}

resource "aws_lb_target_group_attachment" "env-01-lb-tga-vm-2" {
  target_group_arn = aws_lb_target_group.env-01-elb-tgroup.arn
  target_id        = aws_instance.env-01-vm-swarm-2.id
}
