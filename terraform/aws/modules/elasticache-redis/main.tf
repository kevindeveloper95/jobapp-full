resource "aws_elasticache_replication_group" "redis" {
  # Identificación
  replication_group_id       = "${var.project_name}-redis-${var.environment}"
  description                 = "Redis cluster for ${var.project_name}"
  
  # Motor Redis
  engine                      = "redis"
  engine_version              = var.engine_version  # Ej: "7.0"
  
  # Configuración de nodos
  node_type                   = var.node_type  # Ej: "cache.t3.micro"
  port                        = 6379  # Puerto estándar de Redis
  num_cache_clusters          = var.num_cache_clusters  # Número de nodos (1-6)
  
  # Red y seguridad
  subnet_group_name           = var.subnet_group_name  # ← AQUÍ SE CONECTA CON EL SUBNET GROUP
  security_group_ids          = [var.redis_security_group_id]
  
  # Configuración de alta disponibilidad
  automatic_failover_enabled  = var.automatic_failover_enabled  # true para HA
  multi_az_enabled            = var.multi_az_enabled  # true para multi-AZ
  
  # Configuración de snapshot/backup
  snapshot_retention_limit     = var.snapshot_retention_limit  # días
  snapshot_window             = var.snapshot_window  # Ej: "03:00-05:00"
  
  # Para pruebas (permite destruir fácilmente)
  final_snapshot_identifier   = var.final_snapshot_identifier
  
  # Tags
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-redis-${var.environment}"
    }
  )
}