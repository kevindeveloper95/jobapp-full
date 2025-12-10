# EKS Cluster Troubleshooting

## Common Issues

| Problem | Solution |
|---------|----------|
| `kubectl` no se conecta | `aws eks update-kubeconfig --name <cluster-name> --region <region>` |
| Nodos no aparecen | Verificar estado: `eksctl get nodegroup --cluster <cluster-name> --region <region>` (debe ser `ACTIVE`) |
| Pods en `Pending` | Verificar recursos: `kubectl describe pod <pod-name>` |
| Error al crear clúster | Verificar permisos IAM y límites de servicio de AWS |

## Diagnostic Commands

```bash
# Ver eventos del clúster
kubectl get events --all-namespaces --sort-by='.lastTimestamp'

# Ver logs de componentes del sistema
kubectl logs -n kube-system <pod-name>

# Ver estado del nodegroup
eksctl get nodegroup --cluster <cluster-name> --region <region> -o yaml

# Verificar conexión al clúster
kubectl cluster-info

# Ver todos los recursos
kubectl get all --all-namespaces
```

