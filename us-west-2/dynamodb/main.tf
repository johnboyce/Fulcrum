provider "aws" {
  region  = "uswest2"
  profile = "us-west-2"
}

resource "aws_dynamodb_table" "data_table" {
  name         = "FulcrumTable-us-west-2"
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
