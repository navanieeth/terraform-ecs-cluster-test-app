terraform {
  backend "s3" {
    bucket = "terraform-prod-app-eu-west-1"
    key    = "dynamodb/dynamodb.tfstate"
    region = "eu-west-1"
  }
}
