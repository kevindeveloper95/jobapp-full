# Imágenes para Pod Disruption Budget

Coloca las capturas de pantalla en la carpeta `images/` y referencia las imágenes en los READMEs principales usando sintaxis Markdown.

## Estructura

```
pdb/
├── README.md          ← Este archivo (guía)
├── README-PDB.md      ← Documentación principal
├── gateway-pdb.yaml
├── auth-pdb.yaml
└── images/            ← Guarda las imágenes aquí
    ├── pdb-configured.png
    ├── pdb-before-update.png
    └── ...
```

## Cómo referenciar en los READMEs

Usa esta sintaxis en los READMEs principales:

```markdown
![PDB configurado](images/pdb-configured.png)
```

## Imágenes sugeridas:

1. **pdb-configured.png** - PDB creado y configurado
   ```powershell
   kubectl get pdb -n production
   kubectl describe pdb jobber-gateway-pdb -n production
   ```
   Referencia: `![PDB configurado](images/pdb-configured.png)`

2. **pdb-before-update.png** - Estado de pods antes de actualización
   ```powershell
   kubectl get pods -n production -l app=jobber-gateway -o wide
   ```
   Referencia: `![Antes de actualización](images/pdb-before-update.png)`

3. **pdb-during-update.png** - Durante rolling update (siempre hay al menos 1 pod)
   ```powershell
   kubectl get pods -n production -l app=jobber-gateway -w
   ```
   Referencia: `![Durante actualización](images/pdb-during-update.png)`

4. **pdb-after-update.png** - Estado después de actualización
   ```powershell
   kubectl get pods -n production -l app=jobber-gateway -o wide
   ```
   Referencia: `![Después de actualización](images/pdb-after-update.png)`

