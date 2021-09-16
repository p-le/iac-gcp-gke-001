resource "kubernetes_persistent_volume_claim" "wordpress" {
  metadata {
    name = "wordpress-volumeclaim"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "50Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "wordpress" {
  metadata {
    name = "wordpress"
    labels = {
      app = "wordpress"
    }
  }

  spec {
    replicas = var.wordpress.replicas

    selector {
      match_labels = {
        app = "wordpress"
      }
    }

    template {
      metadata {
        labels = {
          app = "wordpress"
        }
      }

      spec {
        # Container Definitions
        container {
          image = "wordpress:${var.wordpress.image_version}"
          name  = "wordpress"
          env {
            name  = "WORDPRESS_DB_HOST"
            value = "mysql:3306"
          }
          env {
            name = "WORDPRESS_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mysql"
                key  = "password"
              }
            }
          }
          port {
            container_port = 80
            name           = "wordpress"
          }
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
          }
          volume_mount {
            name       = "wordpress-persistent-storage"
            mount_path = "/var/www/html"
          }

        }
        # Volumes Definitions
        volume {
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.wordpress.metadata.0.name
          }
        }
      }
    }
  }

  depends_on = [
    null_resource.mysql_secret
  ]
}


resource "kubernetes_service" "wordpress" {
  metadata {
    name = "wordpress"
  }
  spec {
    selector = {
      app = kubernetes_deployment.wordpress.metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}
