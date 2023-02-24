provider "aws" {
  region = "us-east-1"
}

module "lib" {
  source = "../lib/"
}

terraform {
  backend "s3" {
    bucket = "my-s3-bucket-for-tfstate"
    key    = "quest/dev/albecs/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "${var.name}-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster""ecs-cluster" {
  name = "${var.name}-ecs-cluster"
}

resource "aws_ecs_task_definition" "ecs-task-definition" {
  family                   = "${var.name}-task"
   requires_compatibilities = ["FARGATE"]
   cpu    = var.task_definition_cpu
   memory = var.task_definition_memory
  container_definitions    = jsonencode([{
    name   = "${var.name}-task"
    image  = "public.ecr.aws/g4t5d3x4/aws-quest-node-image:latest"
    cpu       = 256
    memory    = 512
    portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
    ]
    log_configuration = {
      log_driver = "awslogs"
      options = {
        "awslogs-create-group"    = "true"
        "awslogs-group"           = "awslogs-quest-td"
        "awslogs-region"          = "us-east-1"
        "awslogs-stream-prefix"   = "awslogs-quest"
      }
    }

    /*environment = [{
      name  = "EXAMPLE_ENV_VAR"
      value = var.example_env_var
    }]*/
  }])
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_ecs_service" "ecs-service" {
  name = "${var.name}-ecs-service"
  cluster = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  launch_type = "FARGATE"
  desired_count = 3

  network_configuration {
    security_groups = ["${aws_security_group.service_security_group.id}"]
    assign_public_ip = true
    subnets         = module.lib.public_subnets
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    container_name = aws_ecs_task_definition.ecs-task-definition.family
    container_port = 3000
  }
}

resource "aws_security_group" "service_security_group" {
  vpc_id = module.lib.vpc_id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.lb_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}





resource "aws_lb" "alb" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.lb_security_group.id}"]
  subnets            = module.lib.public_subnets

  tags = {
    Name = "var.name"
  }
}

resource "aws_security_group" "lb_security_group" {
  vpc_id = module.lib.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource  "aws_lb_target_group" "alb_target_group" {
  name               = var.name
  port               = 80
  protocol           = "HTTP"
  target_type        = "ip"
  vpc_id             = module.lib.vpc_id
 


  health_check {
    healthy_threshold   = 2
    interval            = 30
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    path                = "/"
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