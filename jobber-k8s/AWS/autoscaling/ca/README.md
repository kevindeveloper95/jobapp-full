# Imágenes para Cluster Autoscaler

Coloca las capturas de pantalla en la carpeta `images/` y referencia las imágenes en los READMEs principales usando sintaxis Markdown.

## Estructura

```
ca/
├── README.md          ← Este archivo (guía)
└── images/            ← Guarda las imágenes aquí
    ├── ca-initial-state.png
    ├── ca-pending-pods.png
    └── ...
```

## Cómo referenciar en los READMEs

Usa esta sintaxis en los READMEs principales:

```markdown
![Estado inicial del clúster](images/ca-initial-state.png)
```

## Imágenes sugeridas:

1. **ca-initial-state.png** - Estado inicial del clúster (1 nodo)
   ```bash
   kubectl get nodes
   kubectl get pods -n production -o wide
   ```
   Referencia: `![Estado inicial del clúster](images/ca-initial-state.png)`

2. **ca-pending-pods.png** - Pods en estado Pending antes del escalado
   ```bash
   kubectl get pods -n production | grep Pending
   ```
   Referencia: `![Pods pendientes](images/ca-pending-pods.png)`

3. **ca-logs-scaling.png** - Logs del CA mostrando decisión de escalar
   ```bash
   kubectl -n kube-system logs deployment/cluster-autoscaler | grep -i "scale\|node"
   ```
   Referencia: `![Logs del CA escalando](images/ca-logs-scaling.png)`

4. **ca-new-node.png** - Nuevo nodo creado
   ```bash
   kubectl get nodes
   ```
   Referencia: `![Nuevo nodo creado](images/ca-new-node.png)`

5. **ca-pods-distributed.png** - Pods distribuidos en ambos nodos
   ```bash
   kubectl get pods -n production -o wide
   ```
   Referencia: `![Pods distribuidos](images/ca-pods-distributed.png)`

6. **ca-scale-down.png** - Escalado hacia abajo (cuando la carga baja)
   ```bash
   kubectl -n kube-system logs deployment/cluster-autoscaler | grep -i "scale down"
   ```
   Referencia: `![Escalado hacia abajo](images/ca-scale-down.png)`

