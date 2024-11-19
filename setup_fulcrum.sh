#!/bin/zsh

# Define regions
REGIONS=("us-east-1" "us-west-2")

# Check if script is run inside the project directory
if [[ ! -d ".git" ]]; then
  echo "Please run this script from within the Fulcrum project directory."
  exit 1
fi

# Create directories and files for each region
for REGION in "${REGIONS[@]}"; do
  echo "Creating directory structure for $REGION..."

  # Networking
  mkdir -p $REGION/networking
  cat > $REGION/networking/main.tf <<EOL
provider "aws" {
  region  = "${REGION//-/}"
  profile = "${REGION}"
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
}
EOL

  # DynamoDB
  mkdir -p $REGION/dynamodb
  cat > $REGION/dynamodb/main.tf <<EOL
provider "aws" {
  region  = "${REGION//-/}"
  profile = "${REGION}"
}

resource "aws_dynamodb_table" "data_table" {
  name         = "FulcrumTable-${REGION}"
  hash_key     = "itemNumber"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "itemNumber"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }
}
EOL

  # Redis
  mkdir -p $REGION/redis
  cat > $REGION/redis/main.tf <<EOL
provider "aws" {
  region  = "${REGION//-/}"
  profile = "${REGION}"
}

resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id           = "fulcrum-redis-${REGION}"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
}
EOL

  # Lambda
  mkdir -p $REGION/lambda
  cat > $REGION/lambda/app.py <<EOL
import boto3
import json
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table_name = "FulcrumTable-${REGION}"
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    body = json.loads(event['body'])
    item_number = body['itemNumber']
    status = body['status']
    description = body['description']
    timestamp = int(datetime.utcnow().timestamp())

    table.put_item(Item={
        'itemNumber': item_number,
        'timestamp': timestamp,
        'status': status,
        'description': description
    })

    return {
        'statusCode': 200,
        'body': json.dumps({"message": "Item added successfully!"})
    }
EOL

  cat > $REGION/lambda/main.tf <<EOL
provider "aws" {
  region  = "${REGION//-/}"
  profile = "${REGION}"
}

resource "aws_lambda_function" "fulcrum_lambda" {
  function_name = "FulcrumLambda-${REGION}"
  handler       = "app.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn

  filename         = "app.zip"
  source_code_hash = filebase64sha256("app.zip")
}

resource "aws_iam_role" "lambda_role" {
  name = "FulcrumLambdaRole-${REGION}"

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
EOL

  # API Gateway
  mkdir -p $REGION/api-gateway
  cat > $REGION/api-gateway/main.tf <<EOL
provider "aws" {
  region  = "${REGION//-/}"
  profile = "${REGION}"
}

resource "aws_api_gateway_rest_api" "fulcrum_api" {
  name = "FulcrumAPI-${REGION}"
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
EOL

done

# Create GitHub Actions directory
mkdir -p .github/workflows

# Create workflow for us-east-1
cat > .github/workflows/deploy-us-east-1.yml <<EOL
name: Deploy us-east-1

on:
  push:
    branches:
      - us-east-1

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0

      - name: Deploy us-east-1
        run: |
          cd us-east-1
          terraform init
          terraform apply -auto-approve
EOL

# Create workflow for us-west-2
cat > .github/workflows/deploy-us-west-2.yml <<EOL
name: Deploy us-west-2

on:
  push:
    branches:
      - us-west-2

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0

      - name: Deploy us-west-2
        run: |
          cd us-west-2
          terraform init
          terraform apply -auto-approve
EOL

echo "Fulcrum project structure created successfully!"
