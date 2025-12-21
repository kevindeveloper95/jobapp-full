# RDS MySQL Instance
resource "aws_db_instance" "mysql" {
  # Identificación
  identifier = "${var.project_name}-mysql-${var.environment}"
  
  # Motor de base de datos
  engine         = "mysql"
  engine_version = "8.0.35"  # Versión de MySQL (ajusta según necesites)
  
  # Credenciales
  db_name  = var.database_name
  username = var.master_username
  password = var.master_password  # ⚠️ En producción usa Secrets Manager
  
  # Tipo de instancia y almacenamiento
  instance_class    = var.instance_class  # Ej: "db.t3.micro"
  allocated_storage = var.allocated_storage  # GB
  
  # Red y seguridad
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.mysql_security_group_id]
  
  # Almacenamiento
  storage_type      = "gp3"  # General Purpose SSD
  storage_encrypted = true   # Encriptar datos
  
  # Backup
  backup_retention_period = 7  # días
  backup_window          = "03:00-04:00"  # Ventana de backup
  
  # Mantenimiento
  maintenance_window = "mon:04:00-mon:05:00"
  
  # Para pruebas (permite destruir fácilmente)
  skip_final_snapshot       = true
  final_snapshot_identifier = null
  deletion_protection        = false
  
  # Performance Insights (opcional, cuesta extra)
  performance_insights_enabled = false
  
  # Tags
  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-mysql-${var.environment}"
    }
  )
}
