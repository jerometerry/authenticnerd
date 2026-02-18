# terraform/vpc.tf

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = {
    "jt:my-personal-system:name" = "my-personal-system-vpc"
    "jt:my-personal-system:description" = "Requirement to use MongoDB Atlas VPC Peering"
    "jt:my-personal-system:module" = "vpc"
    "jt:my-personal-system:component" = "core"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${data.aws_region.current.id}a"
  tags              = {
    "jt:my-personal-system:name" = "my-personal-system-private-subnet"
    "jt:my-personal-system:description" = "Allows api-lambda to connect to SSM & KMS"
    "jt:my-personal-system:module" = "vpc"
    "jt:my-personal-system:component" = "core"
  }
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda-sg"
  description = "Allow all outbound traffic for Lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "jt:my-personal-system:name" = "my-personal-system-lambda-sg"
    "jt:my-personal-system:description" = "Security Group for the Lambda function (allows all outbound traffic)"
    "jt:my-personal-system:module" = "vpc"
    "jt:my-personal-system:component" = "api-lambda"
  }
}

resource "aws_security_group" "endpoint_sg" {
  name        = "endpoint-sg"
  description = "Allow inbound HTTPS from the Lambda SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 443 # HTTPS
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  tags = {
    "jt:my-personal-system:name" = "my-personal-system-endpoint-sg"
    "jt:my-personal-system:description" = "Dedicated Security Group for the VPC Endpoints"
    "jt:my-personal-system:module" = "vpc"
    "jt:my-personal-system:component" = "core"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "kms" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.kms"
  vpc_endpoint_type = "Interface"

  subnet_ids          = [aws_subnet.private.id]
  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true
}