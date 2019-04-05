provider "aws" {
  #   access_key = "${var.aws_access_key}"
  #   secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"

  profile = "${var.aws_profile}"
}

# -------------- IAM ------------

#S3 Access Role
resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3_access"
  role = "${aws_iam_role.s3_access_role.name}"
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = "${aws_iam_role.s3_access_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "s3_access_role" {
  name = "s3_access_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
  },
      "Effect": "Allow",
      "Sid": ""
      }
    ]
}
EOF
}

## ----------- IAM -----------
resource "aws_vpc" "wp_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "wp_vpc"
  }
}

#Internet Gateway

resource "aws_internet_gateway" "wp_internet_gateway" {
  vpc_id = "${aws_vpc.wp_vpc.id}"

  tags {
    Name = "wp_igw"
  }
}

## Route Table

resource "aws_route_table" "wp_public_rt" {
  vpc_id = "${aws_vpc.wp_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.wp_internet_gateway.id}"
  }

  tags {
    Name = "wp_public"
  }
}

resource "aws_default_route_table" "wp_private_rt" {
  default_route_table_id = "${aws_vpc.wp_vpc.default_route_table_id}"

  tags {
    Name = "wp_public"
  }
}

#Subnets

resource "aws_subnet" "wp_public1_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["public1"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "wp_public1"
  }
}

resource "aws_subnet" "wp_public2_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["public2"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "wp_public2"
  }
}

resource "aws_subnet" "wp_private1_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["private1"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "wp_private1"
  }
}

resource "aws_subnet" "wp_private2_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["private2"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "wp_private2"
  }
}

resource "aws_subnet" "wp_rds1_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["rds1"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "wp_rds1"
  }
}

resource "aws_subnet" "wp_rds2_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["rds2"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "wp_rds2"
  }
}

resource "aws_subnet" "wp_rds3_subnet" {
  vpc_id                  = "${aws_vpc.wp_vpc.id}"
  cidr_block              = "${var.cidrs["rds3"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[2]}"

  tags {
    Name = "wp_rds3"
  }
}

#rds subnet group

resource "aws_db_subnet_group" "wp_rds_subnetgroup" {
  name = "aws_rds_subnetgroup"

  subnet_ids = [
    "${aws_subnet.wp_rds1_subnet.id}",
    "${aws_subnet.wp_rds2_subnet.id}",
    "${aws_subnet.wp_rds3_subnet.id}",
  ]

  tags {
    Name = "wp_rds_sng"
  }
}

#Subnet Association

resource "aws_route_table_association" "wp_public1_assoc" {
  subnet_id      = "${aws_subnet.wp_public1_subnet.id}"
  route_table_id = "${aws_route_table.wp_public_rt.id}"
}

resource "aws_route_table_association" "wp_public2_assoc" {
  subnet_id      = "${aws_subnet.wp_public2_subnet.id}"
  route_table_id = "${aws_route_table.wp_public_rt.id}"
}

resource "aws_route_table_association" "wp_private1_assoc" {
  subnet_id      = "${aws_subnet.wp_private1_subnet.id}"
  route_table_id = "${aws_default_route_table.wp_private_rt.id}"
}

resource "aws_route_table_association" "wp_private2_assoc" {
  subnet_id      = "${aws_subnet.wp_private2_subnet.id}"
  route_table_id = "${aws_default_route_table.wp_private_rt.id}"
}

#Security Groups

resource "aws_security_group" "wp_dev_sg" {
  name        = "wp_dev_sg"
  description = "Used for access to dev instance"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  # SSH  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow Everything
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

#public security Group

resource "aws_security_group" "wp_public_sg" {
  name        = "wp_public_sg"
  description = "Used by ELB for Public Access"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "wp_private_sg" {
  name        = "wp_private_sg"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

# RDS Security Group

resource "aws_security_group" "wp_rds_sg" {
  name        = "Used for RDS Instance"
  description = "Used for RDS Instance"
  vpc_id      = "${aws_vpc.wp_vpc.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    
    security_groups = [
      "${aws_security_group.wp_dev_sg.id}",
      "${aws_security_group.wp_public_sg.id}",
      "${aws_security_group.wp_private_sg.id}"
    ]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

# VPC Endpoint for S3

resource "aws_vpc_endpoint" "wp_private_s3_endpoint" {
  vpc_id       = "${aws_vpc.wp_vpc.id}"
  service_name = "com.amazonaws.${var.aws_region}.s3"

  route_table_ids = [
    "${aws_vpc.wp_vpc.main_route_table_id}",
    "${aws_route_table.wp_public_rt.id}"
  ]

  policy = <<POLICY
  {
    "Statement" : [{
        "Action" : "*",
        "Effect" : "Allow",
        "Resource" : "*",
        "Principal" : "*"
    }]
  }
  POLICY
}

# S3 Code Bucket

resource "random_id" "wp_code_bucket" {
  byte_length = 2
}

resource "aws_s3_bucket" "code" {
  bucket = "${var.domain_name}_${random_id.wp_code_bucket.dec}"
  acl    = "private"
  force_destroy = true
  tags {
    Name        = "Code bucket"
  }
}

# RDS
resource "aws_db_instance" "wp_db" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "${var.db_instance_class}"
  name                 = "${var.dbname}"
  username             = "${var.dbuser}"
  password             = "${var.dbpassword}"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = "${aws_db_subnet_group.wp_rds_subnetgroup.name}"
  vpc_security_group_ids = ["${aws_security_group.wp_rds_sg.id}"]
  skip_final_snapshot = true
}

# Application Load balancer
resource "aws_lb" "wp_alb" {
  name               = "${var.domain_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.wp_public_sg.id}"]
  subnets            = [
    "${aws_subnet.wp_public1_subnet.id}",
    "${aws_subnet.wp_public2_subnet.id}"
  ]

  enable_deletion_protection = false
  # listener {
  #   instance_port = 80
  #   instance_protocol = "http"
  #   lb_port = 90
  #   lb_protocol = "http"
  # }
  # access_logs {
  #   bucket  = "${aws_s3_bucket.lb_logs.bucket}"
  #   prefix  = "test-lb"
  #   enabled = true
  # }
  tags = {
    Environment = "wp_${var.domain_name}-alb"
  }
}


resource "aws_lb_target_group" "wp_alb_tg" {
	name	= "alb-front-https"
	vpc_id	= "${aws_vpc.wp_vpc.id}"
	port	= "80"
	protocol	= "HTTP"
	health_check {
                path = "/"
                port = "80"
                protocol = "HTTP"
                healthy_threshold = 2
                unhealthy_threshold = 2
                interval = 5
                timeout = 4
                matcher = "200-308"
        }
}

resource "aws_lb_listener" "alb_front_http" {
	load_balancer_arn	=	"${aws_lb.wp_alb.arn}"
	port			=	"80"
	protocol		=	"HTTP"
	default_action {
		target_group_arn	=	"${aws_lb_target_group.wp_alb_tg.arn}"
		type			=	"forward"
	}
}

# DEV Server

resource "aws_key_pair" "wp_auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "wp_dev" {
  ami           = "${var.dev_ami}"
  instance_type = "${var.dev_instance_type}"

  tags {
    Name = "wp_dev"
  }

  key_name = "${aws_key_pair.wp_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.wp_dev_sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.s3_access_profile.id}"
  subnet_id = "${aws_subnet.wp_public1_subnet.id}"

  provisioner "local-exec" {
    command = <<EOD
cat <<EOD > aws_hosts
[dev]
${aws_instance.wp_dev.public_ip}
[dev:vars]
s3code=$(aws_s3_bucket.code.bucket)
domain=${var.domain_name}
    EOF
    EOD
  }

  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.wp_dev.id} --profile superhero && ansible-playbook -i aws_hosts wordpress.yml"
  }  
}


# Golden AMI

resource "random_id" "golden_ami" {
  byte_length = 3
}

resource "aws_ami_from_instance" "wp_golden" {
  name               = "wp_ami-${random_id.golden_ami.b64}"
  source_instance_id = "${aws_instance.wp_dev.id}"

  provisioner "local-exec" {
   command = <<EOT
cat <<EOF > userdata
#!/bin/bash
/usr/bin/aws s3 sync s3://${aws_s3_bucket.code.bucket} /var/www/html/
/bin/touch /var/spool/cron/root
sudo /bin/echo '*/5 * * * * aws s3 sync s3://${aws_s3_bucket.code.bucket} /var/www/html/' >> /var/spool/cron/root
EOF
EOT
  }
}



#launch configuration

resource "aws_launch_configuration" "wp_lc" {
  name_prefix          = "wp_lc-"
  image_id             = "${aws_ami_from_instance.wp_golden.id}"
  instance_type        = "${var.lc_instance_type}"
  security_groups      = ["${aws_security_group.wp_private_sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.s3_access_profile.id}"
  key_name             = "${aws_key_pair.wp_auth.id}"
  user_data            = "${file("userdata")}"

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "wp_asg" {
  name                      = "asg-${aws_launch_configuration.wp_lc.id}"
  max_size                  = "${var.asg_max}"
  min_size                  = "${var.asg_min}"
  health_check_grace_period = "${var.asg_grace}"
  health_check_type         = "${var.asg_hct}"
  desired_capacity          = "${var.asg_cap}"
  force_delete              = true
  load_balancers            = ["${aws_lb.wp_alb.id}"]

  vpc_zone_identifier = ["${aws_subnet.wp_private1_subnet.id}",
    "${aws_subnet.wp_private2_subnet.id}",
  ]

  launch_configuration = "${aws_launch_configuration.wp_lc.name}"

  tag {
    key                 = "Name"
    value               = "wp_asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

#---------Route53-------------

#primary zone

resource "aws_route53_zone" "primary" {
  name              = "${var.domain_name}.${var.domain_ext}"
  delegation_set_id = "${var.delegation_set}"
}

#www 

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "www.${var.domain_name}.com"
  type    = "A"

  alias {
    name                   = "${aws_lb.wp_alb.dns_name}"
    zone_id                = "${aws_lb.wp_alb.zone_id}"
    evaluate_target_health = false
  }
}

#dev 

resource "aws_route53_record" "dev" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "dev.${var.domain_name}.com"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.wp_dev.public_ip}"]
}

#secondary zone

resource "aws_route53_zone" "secondary" {
  name   = "${var.domain_name}.com"
  
  vpc {
    vpc_id = "${aws_vpc.wp_vpc.id}"
  }
}

#db 

resource "aws_route53_record" "db" {
  zone_id = "${aws_route53_zone.secondary.zone_id}"
  name    = "db.${var.domain_name}.com"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_db_instance.wp_db.address}"]
}