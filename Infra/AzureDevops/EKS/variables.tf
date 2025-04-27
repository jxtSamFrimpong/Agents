variable "region" {
  default = "eu-central-1"
}

variable "profile" {
  default = "iam-dev"
}

variable "tags" {
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}