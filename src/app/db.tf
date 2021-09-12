resource "null_resource" "mysql_secret" {
  triggers = {
    script_hash = "${sha256(file("${path.root}/secrets.sh"))}"
  }

  provisioner "local-exec" {
    command = "${path.root}/secrets.sh"
    environment = {
      GCP_PROJECT_ID = var.project_id
    }
  }

  depends_on = [
    google_container_cluster.primary
  ]
}

resource "kubernetes_persistent_volume" "mysql" {
  metadata {
    name = "mysql-volume"
  }
  spec {
    capacity = {
      storage = "50Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      gce_persistent_disk {
        pd_name = "${var.service_name}-mysql"
      }
    }
  }
  depends_on = [
    google_container_cluster.primary
  ]
}

resource "kubernetes_persistent_volume_claim" "mysql" {
  metadata {
    name = "mysql-volumeclaim"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "100Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.mysql.metadata.0.name
  }

  depends_on = [
    google_container_cluster.primary
  ]
}

resource "kubernetes_deployment" "mysql" {
  metadata {
    name = "mysql"
    labels = {
      app = "mysql"
    }
  }

  spec {
    replicas = var.mysql.replicas

    selector {
      match_labels = {
        app = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }

      spec {
        # Container Definitions
        container {
          image = "mysql:${var.mysql.image_version}"
          name  = "mysql"
          args  = ["--default-authentication-plugin=mysql_native_password"]
          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mysql"
                key  = "password"
              }
            }
          }
          port {
            container_port = 3306
            name           = "mysql"
          }
          volume_mount {
            name       = "mysql-persistent-storage"
            mount_path = "/var/lib/mysql"
          }
        }
        # Volumes Definitions
        volume {
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.mysql.metadata.0.name
          }
        }
      }
    }
  }

  depends_on = [
    null_resource.mysql_secret,
    google_container_cluster.primary
  ]
}


resource "kubernetes_service" "mysql" {
  metadata {
    name = "mysql"
  }
  spec {
    selector = {
      app = kubernetes_deployment.mysql.metadata.0.labels.app
    }
    port {
      port        = 3306
      target_port = 3306
    }
    type = "ClusterIP"
  }

  depends_on = [
    google_container_cluster.primary
  ]
}
