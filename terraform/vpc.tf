# terraform/vpc.tf

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "personal-system-vpc" }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${data.aws_region.current.name}a"
  tags              = { Name = "personal-system-private-subnet" }
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
}

# Create a private endpoint for SSM inside your VPC
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids         = [aws_subnet.private.id]
  security_group_ids = [aws_security_group.lambda_sg.id]
  private_dns_enabled = true
}

# Create a private endpoint for KMS inside your VPC
resource "aws_vpc_endpoint" "kms" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.kms"
  vpc_endpoint_type = "Interface"

  subnet_ids         = [aws_subnet.private.id]
  security_group_ids = [aws_security_group.lambda_sg.id]
  private_dns_enabled = true
}