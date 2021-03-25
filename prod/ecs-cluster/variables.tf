variable "aws_region" {}
variable "aws_profile" {}
variable "environment" {}
variable "cluster" {}
variable "key_name" {}
variable "max_size" {}
variable "min_size" {}
variable "desired_capacity" {}
variable "instance_type" {}
variable "ecs_aws_ami" {}
variable "load_balancers" {}
variable "private_subnet_cidrs" {
   type = list
}
variable "my_ecr_arn" {}
