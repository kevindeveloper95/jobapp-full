# Imágenes para VPA

Coloca las capturas de pantalla en la carpeta `images/` y referencia las imágenes en los READMEs principales usando sintaxis Markdown.

## Estructura

```
vpa/
├── README.md          ← Este archivo (guía)
├── README-VPA.md      ← Documentación principal
├── gateway-vpa.yaml
└── images/            ← Guarda las imágenes aquí
    ├── vpa-configured.png
    ├── vpa-recommendations.png
    └── ...
```

## Cómo referenciar en los READMEs

Usa esta sintaxis en los READMEs principales:

```markdown
![VPA configurado](images/vpa-configured.png)
```

## Imágenes sugeridas:

1. **vpa-configured.png** - VPA creado y configurado
   ```powershell
   kubectl get vpa -n production
   kubectl describe vpa jobber-gateway-vpa -n production
   ```
   Referencia: `![VPA configurado](images/vpa-configured.png)`

2. **vpa-recommendations.png** - Recomendaciones del VPA
   ```powershell
   kubectl describe vpa jobber-gateway-vpa -n production | Select-String -Pattern "Recommendation" -Context 0,20
   ```
   Referencia: `![Recomendaciones VPA](images/vpa-recommendations.png)`

3. **vpa-before-after.png** - Comparación antes/después
   - Antes: requests/limits originales del deployment
   - Después: requests/limits recomendados por VPA
   Referencia: `![Comparación antes/después](images/vpa-before-after.png)`

4. **vpa-pod-adjusted.png** - Pod con recursos ajustados (modo Initial)
   ```powershell
   kubectl describe pod <pod-name> -n production | Select-String -Pattern "Requests|Limits"
   ```
   Referencia: `![Pod con recursos ajustados](images/vpa-pod-adjusted.png)`

