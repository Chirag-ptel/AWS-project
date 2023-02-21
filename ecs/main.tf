provider "aws" {
  region = "us-east-1"
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


/*resource "aws_ecs_task_definition" "example_task" {
  family                   = var.task_name
  container_definitions    = jsonencode([{
    name  = "example_container"
    image = var.image_name
    portMappings = [{
      containerPort = var.container_port
    }]
    environment = [{
      name  = "EXAMPLE_ENV_VAR"
      value = var.example_env_var
    }]
  }])
  network_mode             = "awsvpc"
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
}*/
