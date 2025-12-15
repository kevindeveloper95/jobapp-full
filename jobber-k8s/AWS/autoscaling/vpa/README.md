# Images for VPA

Place screenshots in the `images/` folder and reference the images in the main READMEs using Markdown syntax.

## Structure

```
vpa/
├── README.md          ← This file (guide)
├── README-VPA.md      ← Main documentation
├── gateway-vpa.yaml
└── images/            ← Save images here
    ├── vpa-configured.png
    ├── vpa-recommendations.png
    └── ...
```

## How to reference in READMEs

Use this syntax in the main READMEs:

```markdown
![VPA configured](images/vpa-configured.png)
```

## Suggested images:

1. **vpa-configured.png** - VPA created and configured
   ```powershell
   kubectl get vpa -n production
   kubectl describe vpa jobber-gateway-vpa -n production
   ```
   Reference: `![VPA configured](images/vpa-configured.png)`

2. **vpa-recommendations.png** - VPA recommendations
   ```powershell
   kubectl describe vpa jobber-gateway-vpa -n production | Select-String -Pattern "Recommendation" -Context 0,20
   ```
   Reference: `![VPA recommendations](images/vpa-recommendations.png)`

3. **vpa-before-after.png** - Before/after comparison
   - Before: original deployment requests/limits
   - After: VPA recommended requests/limits
   Reference: `![Before/after comparison](images/vpa-before-after.png)`

4. **vpa-pod-adjusted.png** - Pod with adjusted resources (Initial mode)
   ```powershell
   kubectl describe pod <pod-name> -n production | Select-String -Pattern "Requests|Limits"
   ```
   Reference: `![Pod with adjusted resources](images/vpa-pod-adjusted.png)`
