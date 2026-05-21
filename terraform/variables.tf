variable "aws_region" {
  description = "The AWS region to deploy the EC2 instance"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "key_name" {
  description = "The name of the SSH key pair to access the instance"
  type        = string
  default     = "task-manager"
}
