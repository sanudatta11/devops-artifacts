# variable "aws_access_key" {}

# variable "aws_secret_key" {}

variable "aws_region" {}

variable "aws_profile" {}

variable "vpc_cidr" {}

# State can be either: available, information, impaired, or unavailable
data "aws_availability_zones" "available" {}

variable "cidrs" {
  type = "map"
}

variable "localip" {}

variable "domain_name" {}

variable "db_instance_class" {}
variable "dbname" {}

variable "dbuser" {}

variable "dbpassword" {}

variable "alb_interval" {}

variable "alb_healthy_threshold" {}

variable "alb_timeout" {}

variable "alb_unhealthy_threshold" {}

variable "dev_instance_type" {}

variable "dev_ami" {}

variable "public_key_path" {}
variable "key_name" {}

variable "lc_instance_type" {}
variable "asg_max" {}
variable "asg_min" {}

variable "asg_grace" {}

variable "asg_hct" {}

variable "asg_cap" {}

variable "delegation_set" {}
variable "domain_ext" {}
