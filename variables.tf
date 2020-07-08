variable "name" {
  default = "redis-cluster"
}

variable "client_port" {
  default = 6379
}

variable "gossip_port" {
  default = 16379
}

variable "replicas" {
  default = 6
}

variable "service_type" {
  default = "NodePort"
}

variable "image" {
  default = "redis"
}

variable "namespace" {
  default = "redis"
}

variable "resources" {
  default = {
    requests = {
      cpu    = 0
      memory = 0
    }

    limits = {
      cpu    = 1
      memory = "1Gi"
    }
  }
}