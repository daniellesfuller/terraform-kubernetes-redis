module "redis-cluster" {
  source    = "../"
  name      = "redis-cluster"
  image     = "redis"
  namespace = kubernetes_namespace.redis.metadata[0].name
}

resource "kubernetes_namespace" "redis" {
  metadata {
    name = "redis"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels
    ]
  }
}