provider "aws" {
  region  = "useast1"
  profile = "us-east-1"
}

resource "aws_lambda_function" "fulcrum_lambda" {
  function_name = "FulcrumLambda-us-east-1"
  handler       = "app.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn

  filename         = "app.zip"
  source_code_hash = filebase64sha256("app.zip")
}

resource "aws_iam_role" "lambda_role" {
  name = "FulcrumLambdaRole-us-east-1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
