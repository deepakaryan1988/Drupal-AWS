data "terraform_remote_state" "network" {
  backend = "local" # ✅ Use "s3" when you move to remote state
  config = {
    path = "../network/terraform.tfstate"
  }
}

data "terraform_remote_state" "efs" {
  backend = "local"
  config = {
    path = "../efs/terraform.tfstate"
  }
}

data "terraform_remote_state" "rds" {
  backend = "local"
  config = {
    path = "../rds/terraform.tfstate"
  }
}
