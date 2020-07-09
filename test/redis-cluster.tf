module "redis-cluster" {
  source = "../"
  name   = "redis-cluster"
  image  = "redis"
}