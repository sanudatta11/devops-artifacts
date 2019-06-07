resource "aws_vpc" "Production-VPC" {
    cidr_block           = "17.10.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

    tags {
        "Name" = "Production VPC"
    }
}