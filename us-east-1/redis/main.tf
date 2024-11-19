provider "aws" {
  region  = "useast1"
  profile = "us-east-1"
}

resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id           = "fulcrum-redis-us-east-1"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
}
