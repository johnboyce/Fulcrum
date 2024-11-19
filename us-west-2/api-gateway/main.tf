provider "aws" {
  region  = "uswest2"
  profile = "us-west-2"
}

resource "aws_api_gateway_rest_api" "fulcrum_api" {
  name = "FulcrumAPI-us-west-2"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.fulcrum_api.id
  parent_id   = aws_api_gateway_rest_api.fulcrum_api.root_resource_id
  path_part   = "add"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.fulcrum_api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.fulcrum_api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.fulcrum_lambda.invoke_arn
}
