terraform {
  backend "gcs" {
    bucket = "asia-northeast1-terraform-state"
    prefix = "gke-001-app"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "gcs"
  config = {
    bucket  = "asia-northeast1-terraform-state"
    prefix  = "gke-001-app"
  }
}
