variable "name" {
  type = string
  description = "The name prefix for the resource."
}

/*variable "container_definitions" {
  type = list
  description = "A list of container definitions for the task"
}

variable "family" {
  type = string
  description = "The family name for the task definition"
}

variable "network_mode" {
  type = string
  description = "The network mode for the task"
}

variable "task_role_arn" {
  type = string
  description = "The ARN of the IAM role that grants permissions for the task"
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.family
  container_definitions    = var.container_definitions
  network_mode             = var.network_mode
  task_role_arn            = var.task_role_arn
}*/
