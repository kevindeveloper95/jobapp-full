# Images for Cluster Autoscaler

Place screenshots in the `images/` folder and reference the images in the main READMEs using Markdown syntax.

## Structure

```
ca/
├── README.md          ← This file (guide)
└── images/            ← Save images here
    ├── ca-initial-state.png
    ├── ca-pending-pods.png
    └── ...
```

## How to reference in READMEs

Use this syntax in the main READMEs:

```markdown
![Initial cluster state](images/ca-initial-state.png)
```

## Suggested images:

1. **ca-initial-state.png** - Initial cluster state (1 node)
   ```bash
   kubectl get nodes
   kubectl get pods -n production -o wide
   ```
   Reference: `![Initial cluster state](images/ca-initial-state.png)`

2. **ca-pending-pods.png** - Pods in Pending state before scaling
   ```bash
   kubectl get pods -n production | grep Pending
   ```
   Reference: `![Pending pods](images/ca-pending-pods.png)`

3. **ca-logs-scaling.png** - CA logs showing scaling decision
   ```bash
   kubectl -n kube-system logs deployment/cluster-autoscaler | grep -i "scale\|node"
   ```
   Reference: `![CA logs scaling](images/ca-logs-scaling.png)`

4. **ca-new-node.png** - New node created
   ```bash
   kubectl get nodes
   ```
   Reference: `![New node created](images/ca-new-node.png)`

5. **ca-pods-distributed.png** - Pods distributed across both nodes
   ```bash
   kubectl get pods -n production -o wide
   ```
   Reference: `![Distributed pods](images/ca-pods-distributed.png)`

6. **ca-scale-down.png** - Scale down (when load decreases)
   ```bash
   kubectl -n kube-system logs deployment/cluster-autoscaler | grep -i "scale down"
   ```
   Reference: `![Scale down](images/ca-scale-down.png)`
