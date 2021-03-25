terraform {
  backend "s3" {
    bucket         = "terraform-dev-app-eu-west-1"
    key            = "ecs/ecs.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-state-lock-dynamo"
  }
}