provider "aws" {
  region = "us-east-1"
}

module "lib" {
  source = "../lib/"
}

/*data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "my-s3-bucket-for-tfstate"
    key    = "quest/dev/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}*/

terraform {
  backend "s3" {
    bucket = "my-s3-bucket-for-tfstate"
    key    = "quest/dev/alb/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_lb" "alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.lib.default_security_group_id]
  subnets            = module.lib.public_subnets

  tags = {
    Name = "my-alb"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name_prefix        = "my-tg"
  port               = 80
  protocol           = "HTTP"
  target_type        = "ip"
  vpc_id             = module.lib.vpc_id

 /* health_check {
    healthy_threshold   = 2
    interval            = 30
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    path                = "/health"
  }*/

  tags = {
    Name = "my-tg"
  }
}

/*resource "aws_lb_target_group_attachment" "alb_tg_attachment" {
  target_group_arn = aws_lb_target_group.alb_target_group.arn
  target_id        = aws_instance.web.id
  port             = 80
}*/

