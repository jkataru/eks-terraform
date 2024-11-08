terraform {
  backend "s3" {
    bucket         = "sow-tf"
    key            = "sow/terraform.tfstate" 
    region         = "us-east-1"                    
  }
}
