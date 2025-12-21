# ============================================================================
# ⚠️  INSTRUCCIONES PARA CREAR LA KEY PAIR ⚠️
# ============================================================================
# Este módulo crea una Key Pair en AWS para conectarte por SSH a instancias EC2.
#
# ANTES de ejecutar terraform apply, DEBES seguir estos pasos:
#
# PASO 1: Generar las claves SSH
#   PowerShell:
#     ssh-keygen -t rsa -b 4096 -f ~/.ssh/jobapp-key -N '""'
#   
#   Bash/Linux/Mac:
#     ssh-keygen -t rsa -b 4096 -f ~/.ssh/jobapp-key -N ""
#
#   Esto crea:
#     - ~/.ssh/jobapp-key      (clave privada - NO subir a Git)
#     - ~/.ssh/jobapp-key.pub  (clave pública - usar en Terraform)
#
# PASO 2: Leer el contenido de la clave pública
#   PowerShell:
#     Get-Content ~/.ssh/jobapp-key.pub
#   
#   Bash/Linux/Mac:
#     cat ~/.ssh/jobapp-key.pub
#
# PASO 3: Copiar TODO el contenido (una línea que empieza con "ssh-rsa")
#   Ejemplo: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... usuario@hostname
#
# PASO 4: Agregar a terraform.tfvars
#   ec2_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... usuario@hostname"
#   (Pega el contenido completo en una sola línea)
#
# PASO 5: Ejecutar Terraform
#   terraform plan
#   terraform apply
#
# PASO 6: Guardar la clave privada de forma segura
#   - La clave privada (~/.ssh/jobapp-key) es necesaria para conectarte por SSH
#   - NO la subas a Git (ya está en .gitignore)
#   - Guárdala de forma segura
#
# CUANDO CREES EL CLUSTER EKS:
#   Usa: key_name = module.key_pair.key_name
#   En la configuración de los Node Groups
#
# PARA CONECTARTE POR SSH (después de crear instancias):
#   ssh -i ~/.ssh/jobapp-key ec2-user@<IP-de-la-instancia>
#
# ============================================================================

# AWS Key Pair
resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-key-${var.environment}"
  public_key = var.public_key

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-key-${var.environment}"
    }
  )
}