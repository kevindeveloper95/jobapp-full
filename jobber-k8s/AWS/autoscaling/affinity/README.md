# Imágenes para Pod Affinity/Anti-Affinity

Coloca las capturas de pantalla en la carpeta `images/` y referencia las imágenes en los READMEs principales usando sintaxis Markdown.

## Estructura

```
affinity/
├── README.md          ← Este archivo (guía)
└── images/            ← Guarda las imágenes aquí
    ├── affinity-before.png
    ├── affinity-distributed.png
    └── ...
```

## Cómo referenciar en los READMEs

Usa esta sintaxis en los READMEs principales:

```markdown
![Estado inicial con affinity](images/affinity-before.png)
```

## Imágenes sugeridas:

1. **affinity-before.png** - Estado inicial (1 réplica, 1 nodo)
   ```bash
   kubectl get pods -n production -o wide
   kubectl get nodes
   ```
   Referencia: `![Estado inicial](images/affinity-before.png)`

2. **affinity-distributed.png** - Después de escalar (2 réplicas, 2 nodos, cada una en nodo diferente)
   ```bash
   kubectl get pods -n production -o wide
   ```
   Referencia: `![Pods distribuidos](images/affinity-distributed.png)`

3. **affinity-describe.png** - Describe del pod mostrando reglas de affinity
   ```bash
   kubectl describe pod <pod-name> -n production
   ```
   Referencia: `![Describe del pod](images/affinity-describe.png)`

4. **affinity-events.png** - Eventos del scheduler relacionados con affinity
   ```bash
   kubectl get events -n production --sort-by='.lastTimestamp' | grep -i affinity
   ```
   Referencia: `![Eventos del scheduler](images/affinity-events.png)`

5. **affinity-jsonpath.png** - Distribución con JSONPath
   ```bash
   kubectl get pods -n production -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\n"}{end}' | sort
   ```
   Referencia: `![Distribución JSONPath](images/affinity-jsonpath.png)`

