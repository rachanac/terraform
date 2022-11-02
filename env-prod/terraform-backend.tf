# store the terraform state file in s3

 
terraform {
  backend "s3" {
    bucket    = "terraform-state-test-rkc"
    key       = "test/rkc/test.tfstate"
    region    = "ap-south-1"
    profile   = "default"
    #shared_credentials_file = "~/.aws/credentials_mylab"
  }
}

 