# Images for Pod Affinity/Anti-Affinity

Place screenshots in the `images/` folder and reference the images in the main READMEs using Markdown syntax.

## Structure

```
affinity/
├── README.md          ← This file (guide)
└── images/            ← Save images here
    ├── affinity-before.png
    ├── affinity-distributed.png
    └── ...
```

## How to reference in READMEs

Use this syntax in the main READMEs:

```markdown
![Initial state with affinity](images/affinity-before.png)
```

## Suggested images:

1. **affinity-before.png** - Initial state (1 replica, 1 node)
   ```bash
   kubectl get pods -n production -o wide
   kubectl get nodes
   ```
   Reference: `![Initial state](images/affinity-before.png)`

2. **affinity-distributed.png** - After scaling (2 replicas, 2 nodes, each on different node)
   ```bash
   kubectl get pods -n production -o wide
   ```
   Reference: `![Distributed pods](images/affinity-distributed.png)`

3. **affinity-describe.png** - Pod describe showing affinity rules
   ```bash
   kubectl describe pod <pod-name> -n production
   ```
   Reference: `![Pod describe](images/affinity-describe.png)`

4. **affinity-events.png** - Scheduler events related to affinity
   ```bash
   kubectl get events -n production --sort-by='.lastTimestamp' | grep -i affinity
   ```
   Reference: `![Scheduler events](images/affinity-events.png)`

5. **affinity-jsonpath.png** - Distribution with JSONPath
   ```bash
   kubectl get pods -n production -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\n"}{end}' | sort
   ```
   Reference: `![JSONPath distribution](images/affinity-jsonpath.png)`
