variable "environment" {
  type        = string
  description = "Which environment? (dev/stage/test/prod)"
  validation {
    condition     = contains(["dev", "stage", "test", "prod"], var.environment)
    error_message = "Environment name must be one of these values: dev/stage/test/prod."
  }
}

variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP Region"
}

variable "service_name" {
  type        = string
  description = "Which service's infra"
}

variable "cluster_settings" {
  type = object({
    zone         = string
    machine_type = string
  })
  description = "GKE cluster settings"
}

variable "wordpress" {
  type = object({
    replicas      = string
    image_version = string
  })
  description = "Wordpress settings (Deployments, Service)"
}

variable "mysql" {
  type = object({
    replicas      = string
    image_version = string
  })
  description = "MySQL settings (Deployments, Service)"
}
