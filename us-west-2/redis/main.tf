provider "aws" {
  region  = "uswest2"
  profile = "us-west-2"
}

resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id           = "fulcrum-redis-us-west-2"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
}
