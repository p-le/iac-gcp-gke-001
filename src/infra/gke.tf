resource "google_service_account" "default" {
  account_id   = "${var.environment}-${var.service_name}-sa"
  display_name = "Service Account for ${var.service_name}"
}

resource "google_container_cluster" "primary" {
  name       = "${var.environment}-${var.service_name}-cluster"
  location   = var.cluster_settings.zone
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
  master_auth {
    # Empty, disable basic authentication to master
    username = ""
    password = ""
  }
  remove_default_node_pool = true
  initial_node_count       = 1

  timeouts {
    create = "10m"
    delete = "10m"
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "${var.environment}-${var.service_name}-preemptible-pool"
  location   = var.cluster_settings.zone
  cluster    = google_container_cluster.primary.name
  node_count = 2

  node_config {
    preemptible     = true
    machine_type    = var.cluster_settings.machine_type
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      service     = var.service_name
      environment = var.environment
    }
    tags = [
      "gke-node",
      "${var.service_name}-gke"
    ]
  }
}
