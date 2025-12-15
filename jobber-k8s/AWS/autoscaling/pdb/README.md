# Images for Pod Disruption Budget

Place screenshots in the `images/` folder and reference the images in the main READMEs using Markdown syntax.

## Structure

```
pdb/
├── README.md          ← This file (guide)
├── README-PDB.md      ← Main documentation
├── gateway-pdb.yaml
├── auth-pdb.yaml
└── images/            ← Save images here
    ├── pdb-configured.png
    ├── pdb-before-update.png
    └── ...
```

## How to reference in READMEs

Use this syntax in the main READMEs:

```markdown
![PDB configured](images/pdb-configured.png)
```

## Suggested images:

1. **pdb-configured.png** - PDB created and configured
   ```powershell
   kubectl get pdb -n production
   kubectl describe pdb jobber-gateway-pdb -n production
   ```
   Reference: `![PDB configured](images/pdb-configured.png)`

2. **pdb-before-update.png** - Pod state before update
   ```powershell
   kubectl get pods -n production -l app=jobber-gateway -o wide
   ```
   Reference: `![Before update](images/pdb-before-update.png)`

3. **pdb-during-update.png** - During rolling update (always at least 1 pod)
   ```powershell
   kubectl get pods -n production -l app=jobber-gateway -w
   ```
   Reference: `![During update](images/pdb-during-update.png)`

4. **pdb-after-update.png** - State after update
   ```powershell
   kubectl get pods -n production -l app=jobber-gateway -o wide
   ```
   Reference: `![After update](images/pdb-after-update.png)`
