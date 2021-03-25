terraform {
  backend "s3" {
    bucket = "terraform-dev-app-eu-west-1"
    key    = "dynamodb/dynamodb.tfstate"
    region = "eu-west-1"
  }
}
