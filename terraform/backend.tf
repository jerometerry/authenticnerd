# terraform/backend.tf

# -----------------------------------------------------------------------------
# DATA SOURCES
# -----------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# CUSTOM KMS KEY FOR SSM ENCRYPTION
# -----------------------------------------------------------------------------
resource "aws_kms_key" "ssm_key" {
  description             = "KMS key for encrypting SSM parameters for personal-system"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "ssm_key_alias" {
  name          = "alias/personal-system-ssm-key"
  target_key_id = aws_kms_key.ssm_key.id
}

data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow Lambda to Decrypt"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.lambda_exec_role.arn]
    }
    actions   = ["kms:Decrypt"]
    resources = ["*"]
  }
}

resource "aws_kms_key_policy" "ssm_key_policy" {
  key_id = aws_kms_key.ssm_key.id
  policy = data.aws_iam_policy_document.kms_key_policy.json
}

# -----------------------------------------------------------------------------
# SSM PARAMETER FOR MONGODB URI
# -----------------------------------------------------------------------------
resource "aws_ssm_parameter" "mongo_uri" {
  name   = "/MyPersonalSystem/MongoUri"
  type   = "SecureString"
  key_id = aws_kms_key.ssm_key.id
  value  = "placeholder-to-be-updated-manually-in-aws-console"

  lifecycle {
    ignore_changes = [value]
  }
}

# -----------------------------------------------------------------------------
# LAMBDA IAM ROLE & POLICY
# -----------------------------------------------------------------------------
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-policy"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action   = "ssm:GetParameter",
        Effect   = "Allow",
        Resource = aws_ssm_parameter.mongo_uri.arn
      },
      {
        Action   = "kms:Decrypt",
        Effect   = "Allow",
        Resource = aws_kms_key.ssm_key.arn
      },
      {
        Action   = "kms:Decrypt",
        Effect   = "Allow",
        Resource = "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:alias/aws/lambda"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# -----------------------------------------------------------------------------
# LAMBDA FUNCTION
# -----------------------------------------------------------------------------
resource "aws_lambda_function" "api_lambda" {
  function_name    = "personal-system-api"
  filename         = "../backend.zip"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "app.lambda_function.handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("../backend.zip")
  timeout          = 15

  environment {
    variables = {
      MONGO_URI_PARAM_NAME = aws_ssm_parameter.mongo_uri.name
      FRONTEND_URL         = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

# -----------------------------------------------------------------------------
# API GATEWAY (HTTP API)
# -----------------------------------------------------------------------------
resource "aws_apigatewayv2_api" "http_api" {
  name          = "personal-system-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.api_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "api_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gw_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
