resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service" "this" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  spec {
    port {
      name        = "client"
      port        = var.client_port
      target_port = var.client_port
    }

    port {
      name        = "gossip"
      port        = var.gossip_port
      target_port = var.gossip_port
    }

    selector = {
      app = var.name
    }

    type = var.service_type
  }
}

resource "kubernetes_config_map" "this" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    "redis.conf" = "cluster-enabled yes\ncluster-require-full-coverage no\ncluster-node-timeout 15000\ncluster-config-file /data/nodes.conf\ncluster-migration-barrier 1\nappendonly yes\nprotected-mode no\n"

    "update-node.sh" = "#!/bin/sh\nREDIS_NODES=\"/data/nodes.conf\"\nsed -i -e \"/myself/ s/[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}/$${POD_IP}/\" $${REDIS_NODES}\nexec \"$@\"\n"
  }
}

resource "kubernetes_deployment" "this" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.this.metadata[0].name

    labels = {
      app = var.name
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = var.name
      }
    }

    template {
      metadata {
        labels = {
          app = var.name
        }
      }

      spec {
        volume {
          name = "conf"

          config_map {
            name         = var.name
            default_mode = "0755"
          }
        }

        container {
          name    = var.name
          image   = var.image
          command = ["/conf/update-node.sh", "redis-server", "/conf/redis.conf"]

          resources {
            requests {
              cpu    = var.resources.requests.cpu
              memory = var.resources.requests.memory
            }

            limits {
              cpu    = var.resources.limits.cpu
              memory = var.resources.limits.memory
            }
          }

          port {
            name           = "client"
            container_port = var.client_port
          }

          port {
            name           = "gossip"
            container_port = var.gossip_port
          }

          env {
            name = "POD_IP"

            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          volume_mount {
            name       = "conf"
            mount_path = "/conf"
          }

          readiness_probe {
            exec {
              command = ["sh", "-c", "sleep 60"]
            }

            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }
  }
}

