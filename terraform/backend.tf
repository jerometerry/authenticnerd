# terraform/backend.tf
resource "aws_kms_key" "ssm_key" {
  description             = "KMS key for encrypting SSM parameters for personal-system"
  deletion_window_in_days = 7

  tags = {
    "jt:my-personal-system:name" = "ssm_key"
    "jt:my-personal-system:description" = "KMS key for encrypting SSM parameters for personal-system"
    "jt:my-personal-system:module" = "backend"
    "jt:my-personal-system:component" = "core"
  }
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

resource "aws_ssm_parameter" "mongo_uri" {
  name   = "/MyPersonalSystem/MongoUri"
  type   = "SecureString"
  key_id = aws_kms_key.ssm_key.id
  value  = var.atlas_connection_string

  tags = {
    "jt:my-personal-system:name" = "mongo_uri"
    "jt:my-personal-system:description" = "Connection string to the MongoDB Atlas DB"
    "jt:my-personal-system:module" = "backend"
    "jt:my-personal-system:component" = "mongodb-atlas"
  }
}

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

  tags = {
    "jt:my-personal-system:name" = "lambda_exec_role"
    "jt:my-personal-system:description" = "IAM Role for the api-lambda to execute FastAPI"
    "jt:my-personal-system:module" = "backend"
    "jt:my-personal-system:component" = "api-lambda"
  }
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
        Resource = "arn:aws:kms:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:alias/aws/lambda"
      }
    ]
  })

  tags = {
    "jt:my-personal-system:name" = "lambda_exec_role",
    "jt:my-personal-system:description" = "IAM Role for the api-lambda to execute FastAPI",
    "jt:my-personal-system:module" = "backend",
    "jt:my-personal-system:component" = "api-lambda"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "api_lambda" {
  function_name    = "personal-system-api"
  filename         = "../api_lambda_function.zip"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "app.lambda_function.handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("../api_lambda_function.zip")
  timeout          = 15

  environment {
    variables = {
      MONGO_URI_PARAM_NAME = aws_ssm_parameter.mongo_uri.name
      WEBSITE_CLOUDFRONT_URL = "https://${aws_cloudfront_distribution.website_cloudformation_distribution.domain_name}"
      WEBSITE_ALTERNATE_DOMAIN = "https://${var.website_subdomain_name}.${var.domain_name}"
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  tags = {
    "jt:my-personal-system:name" = "api_lambda"
    "jt:my-personal-system:description" = "Lambda Funcation that executes FastAPI"
    "jt:my-personal-system:module" = "backend"
    "jt:my-personal-system:component" = "api-lambda"
  }
}

resource "aws_api_gateway_rest_api" "rest_api_gateway" {
  name        = "my-personal-system-rest-api"
  description = "REST API Gateway that forwards requests to the API Lambda Function"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

   tags = {
    "jt:my-personal-system:name" = "my-personal-system-rest-api"
    "jt:my-personal-system:description" = "REST API Gateway that forwards requests to the API Lambda Function"
    "jt:my-personal-system:module" = "backend"
    "jt:my-personal-system:component" = "api-gateway"
  }
}

resource "aws_api_gateway_resource" "base_rest_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.rest_api_gateway.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "proxy_rest_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id
  parent_id   = aws_api_gateway_resource.base_rest_api_resource.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "rest_api_method" {
  rest_api_id = "${aws_api_gateway_rest_api.rest_api_gateway.id}"
  resource_id = "${aws_api_gateway_resource.proxy_rest_api_resource.id}"
  http_method = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "rest_api_proxy_integration" {
  rest_api_id              = "${aws_api_gateway_rest_api.rest_api_gateway.id}"
  resource_id              = "${aws_api_gateway_resource.proxy_rest_api_resource.id}"
  http_method              = "${aws_api_gateway_method.rest_api_method.http_method}"
  type                     = "AWS_PROXY"
  integration_http_method  = "POST"
  uri                      = aws_lambda_function.api_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "rest_api_deployment" {
  depends_on = [aws_api_gateway_method.rest_api_method]
  rest_api_id = "${aws_api_gateway_rest_api.rest_api_gateway.id}"

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy_rest_api_resource.id,
      aws_api_gateway_method.rest_api_method.id,
      aws_api_gateway_integration.rest_api_proxy_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.rest_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gateway.id
  stage_name    = "v1"
}

resource "aws_lambda_permission" "rest_api_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.rest_api_gateway.execution_arn}/*/*/*"
}

resource "aws_wafv2_web_acl_association" "rest_api_waf_association" {
  resource_arn = aws_api_gateway_stage.api_stage.arn
  web_acl_arn  = aws_wafv2_web_acl.api_waf.arn
}