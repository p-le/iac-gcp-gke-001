terraform {
  backend "gcs" {
    bucket = "asia-northeast1-terraform-state"
    prefix = "gke-001"
  }
}
