# Database Troubleshooting

## Common Issues

| Problem | Solution |
|---------|----------|
| Pod de base de datos en `Pending` | Verificar PersistentVolumeClaim: `kubectl get pvc -n <namespace>`. Verificar recursos disponibles: `kubectl describe pod <pod-name>` |
| No se puede conectar a la base de datos | Verificar Service: `kubectl get svc -n <namespace>`. Usar DNS interno: `<service>.<namespace>.svc.cluster.local` |
| Datos perdidos después de reiniciar | Verificar PersistentVolume montado: `kubectl describe pod <pod-name>`. Verificar PVC: `kubectl get pvc -n <namespace>` |
| RDS no accesible desde pods | Verificar Security Groups y subnet groups. Verificar que el Security Group de RDS permite tráfico desde el Security Group de los pods |

## Diagnostic Commands

```bash
# Verificar StatefulSets
kubectl get statefulsets -n <namespace>

# Verificar PersistentVolumes
kubectl get pv

# Verificar PersistentVolumeClaims
kubectl get pvc -n <namespace>

# Verificar Services
kubectl get svc -n <namespace>

# Conectar a MySQL
kubectl exec -it -n <namespace> statefulset/<mysql-statefulset> -- mysql -uroot -p

# Conectar a PostgreSQL
kubectl exec -it -n <namespace> statefulset/<postgres-statefulset> -- psql -U <user>

# Conectar a MongoDB
kubectl exec -it -n <namespace> statefulset/<mongo-statefulset> -- mongosh

# Ver logs de base de datos
kubectl logs -n <namespace> statefulset/<db-statefulset>
```

