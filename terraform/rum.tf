resource "aws_cognito_identity_pool" "web_rum_pool" {
  identity_pool_name               = "web-rum-pool"
  allow_unauthenticated_identities = true
}

resource "aws_iam_role" "web_rum_guest_role" {
  name = "WebRumGuestRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Condition = {
          "StringEquals" = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.web_rum_pool.id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "unauthenticated"
          }
        }
      }
    ]
  })
}

resource "aws_cognito_identity_pool_roles_attachment" "web_rum_attachment" {
  identity_pool_id = aws_cognito_identity_pool.web_rum_pool.id
  roles = {
    "unauthenticated" = aws_iam_role.web_rum_guest_role.arn
  }
}