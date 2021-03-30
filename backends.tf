terraform {
  backend "remote" {
    organization = "my-terraform"

    workspaces {
      name = "icinga2-aws"
    }
  }
}