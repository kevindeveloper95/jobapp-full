resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-elasticache-subnet-group-${var.environment}"
  subnet_ids = var.subnet_ids  # Lista de IDs de subnets
  
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-elasticache-subnet-group-${var.environment}"
    }
  )
}