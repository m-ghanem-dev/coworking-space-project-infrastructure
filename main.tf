terraform {
  backend "s3" {
    bucket = "s3-tf-backend-mydemo"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}
