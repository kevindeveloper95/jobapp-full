# Security & IAM Troubleshooting

## Common Issues

| Problem | Solution |
|---------|----------|
| Pod no puede asumir IAM role | Verificar OIDC provider: `aws eks describe-cluster --name <cluster-name> --query "cluster.identity.oidc.issuer"`. Verificar Service Account tiene anotación: `eks.amazonaws.com/role-arn` |
| Pod no puede acceder a S3/Secrets Manager | Verificar IAM role tiene permisos: `aws iam list-attached-role-policies --role-name <role-name>` |
| Security Group bloquea tráfico | Verificar reglas: `aws ec2 describe-security-groups --group-ids <sg-id> --region <region>` |
| No se puede conectar a MySQL | Verificar Security Group `<sg-mysql-id>` permite puerto 3306 desde el Security Group del servicio |
| No se puede conectar a PostgreSQL | Verificar Security Group `<sg-postgres-id>` permite puerto 5432 desde el Security Group del servicio |
| No se puede conectar a Redis | Verificar Security Group `<sg-redis-id>` permite puerto 6379 desde el Security Group del servicio |
| Secret no encontrado | Verificar que existe: `kubectl get secrets -n <namespace>` |

## Diagnostic Commands

```bash
# Verificar OIDC provider
aws eks describe-cluster --name <cluster-name> --region <region> --query "cluster.identity.oidc.issuer"

# Verificar Service Account con IAM role
kubectl get serviceaccount <sa-name> -n <namespace> -o yaml

# Verificar IAM policies de un rol
aws iam list-attached-role-policies --role-name <role-name>

# Verificar Security Group
aws ec2 describe-security-groups --group-ids <sg-id> --region <region>

# Verificar reglas de entrada/salida
aws ec2 describe-security-groups --group-ids <sg-id> --query 'SecurityGroups[0].IpPermissions' --region <region>
aws ec2 describe-security-groups --group-ids <sg-id> --query 'SecurityGroups[0].IpPermissionsEgress' --region <region>

# Verificar Secrets
kubectl get secrets -n <namespace>
kubectl describe secret <secret-name> -n <namespace>
```

