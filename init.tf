terraform {
  backend "local" {}
}

provider "aws" {
  region = "eu-west-1"
}

terraform {
  required_providers {
    aws = {
      version = "~> 3.18.0"
    }
  }
}

# Access - ssh based access to the cluster

variable "admin_ssh_key_name" {
  type    = string
  default = "makevoid" # load your key in aws console and then edit this field with your ssh pubkey "file name"
}

# Config:

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "ami_base_vm_debian_10" {
  type    = string
  default = "ami-04e905a52ec8010b2" # see AWS marketplace - https://aws.amazon.com/marketplace/search/results?searchTerms=ami-00b951edb5915f3a8
}

variable "compute_ec2_vm_size" {
  type    = string
  default = "c5.large"
}
