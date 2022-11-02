
# Define Provider

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.24.0"
      
    }
  }
}

/**
# Define Default Tags

provider "aws" {

  region = "us-west-2"
  
  default_tags {
    tags = {
      environment = "Production"
    }
  }

}
*/