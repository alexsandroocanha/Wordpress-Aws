resource "aws_lb_target_group" "wp" {
  name        = "tg-wp-80"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc-wordpress.id

  health_check {
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  stickiness {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = 3600
  }

  tags = {
    Name = "tg-wp-80"
  }
}

resource "aws_lb" "wp" {
  name                       = "alb-wp"
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = [aws_subnet.publica1.id, aws_subnet.publica2.id]
  idle_timeout               = 60
  enable_deletion_protection = false
  tags                       = { Name = "alb-wp" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.wp.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wp.arn
  }
}

resource "aws_autoscaling_group" "wp" {
  name                      = "asg-wp"
  min_size                  = 2
  desired_capacity          = 2
  max_size                  = 4
  health_check_type         = "ELB"
  health_check_grace_period = 120

  vpc_zone_identifier = [
    aws_subnet.privada1.id
  ]

  target_group_arns = [aws_lb_target_group.wp.arn]

  launch_template {
    id      = aws_launch_template.wp.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "wp-app"
    propagate_at_launch = true
  }
}
