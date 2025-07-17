data "terraform_remote_state" "network" {
  backend = "local" # ✅ Use "s3" when you move to remote state
  config = {
    path = "../network/terraform.tfstate"
  }
}
