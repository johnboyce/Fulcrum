provider "aws" {
  region  = "useast1"
  profile = "us-east-1"
}

resource "aws_dynamodb_table" "data_table" {
  name         = "FulcrumTable-us-east-1"
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
