resource "aws_dynamodb_table" "tf-dynamodb" {
  name           = "terraform-state-lock-dynamo"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table"
  }
}
