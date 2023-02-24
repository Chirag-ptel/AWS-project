provider "aws" {
  region = "us-east-1"
}

module "lib" {
  source = "../lib/"
}

terraform {
  backend "s3" {
    bucket = "my-s3-bucket-for-tfstate"
    key    = "quest/dev/ecs/terraform.tfstate"
    region = "us-east-1"
  }
}


resource "aws_iam_role" "ecs_task_execution_role" {
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

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = "${aws_iam_role.ecs_task_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution_policy" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name   = "ecs-task-execution-policy"
  role   = aws_iam_role.ecs_task_execution_role.name
  policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
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
    name   = "${var.name}-container"
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
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_security_group" "service_security_group" {
  vpc_id = module.lib.vpc_id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["sg-0abfba7b686cff5b7"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "ecs-service" {
  name = "${var.name}-ecs-service"
  cluster = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  launch_type = "FARGATE"
  desired_count = var.desired-td-count

  network_configuration {
    security_groups = ["${aws_security_group.service_security_group.id}"]
    assign_public_ip = true  
    subnets         = module.lib.private_subnets
  }

  load_balancer {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:155358046204:targetgroup/quest-dev-alb/6754b4c4e28447dd"
    container_name = "${var.name}-container"
    container_port = 3000
  }
}

output "ecs-service-id" {
  value = aws_ecs_service.ecs-service.id
}
