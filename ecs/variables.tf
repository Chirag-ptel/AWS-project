variable "name" {
  type = string
  description = "The name prefix for the resource."
}

/*variable "container_definitions" {
  type = list
  description = "A list of container definitions for the task"
}*/

variable "container_image" {
  type = string
  description = "the image used to start the container"
  
}

variable "task_container_port" {
  description = "The port number on the container that is bound to the user-specified or automatically assigned host port"
  type        = number
  default     = 80
}

variable "task_host_port" {
  description = "The port number on the container instance to reserve for your container."
  type        = number
  default     = 80
}

variable "task_definition_cpu" {
  description = "Amount of CPU to reserve for the task."
  default     = 256
  type        = number
}

variable "task_definition_memory" {
  description = "The soft limit (in MiB) of memory to reserve for the task."
  default     = 512
  type        = number
}

/*variable "family" {
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
}*/

variable "desired-td-count" {
  type = string
  description = "The count of the task's desired count"
  default = "1"
}



