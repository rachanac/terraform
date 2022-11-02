# store the terraform state file in s3

 
terraform {
  backend "s3" {
    bucket    = "terraform-state-reduxlab-rkc"
    key       = "test/rkc/test.tfstate"
    region    = "us-east-1"
    profile   = "default"
  }
}

 