# terraform/backend.tf

# 1. A secure place to store your MongoDB connection string
resource "aws_ssm_parameter" "mongo_uri" {
  name  = "/MyPersonalSystem/MongoUri"
  type  = "SecureString"
  value = "mongodb+srv://<user>:<password>@cluster..." # <-- PASTE YOUR URI HERE
}

# 2. An IAM role for the Lambda function to run with
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

# 3. Policy allowing the Lambda to write logs and read the secret
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
        Action   = "ssm:GetParameters",
        Effect   = "Allow",
        Resource = aws_ssm_parameter.mongo_uri.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# 4. The Lambda function itself
resource "aws_lambda_function" "api_lambda" {
  function_name = "personal-system-api"
  filename      = "../backend.zip" # Points to the zip file we created
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "main.handler"   # For Mangum, this is "filename.handler"
  runtime       = "python3.12"
  source_code_hash = filebase64sha256("../backend.zip")

  environment {
    variables = {
      MONGO_URI_PARAM_NAME = aws_ssm_parameter.mongo_uri.name
    }
  }
}

# 5. The API Gateway (HTTP API - cheaper and simpler)
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
  route_key = "ANY /{proxy+}" # Routes all requests to the Lambda
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# 6. Permission for API Gateway to invoke the Lambda
resource "aws_lambda_permission" "api_gw_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

# 7. Output the API URL
output "api_endpoint_url" {
  value = aws_apigatewayv2_stage.default_stage.invoke_url
}
