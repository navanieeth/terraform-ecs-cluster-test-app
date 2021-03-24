resource "aws_vpc" "test-vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true

  tags = {
    Name        = var.vpcname
    Environment = var.environment
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Environment = var.environment
  }
  lifecycle {
    prevent_destroy = true
  }
}