# Monitoring Screenshots

This directory contains screenshots and visual documentation of the monitoring setup for the Jobber platform using Elastic Stack (Elasticsearch, Kibana, Heartbeat, and Metricbeat).

---

## 📊 Images Overview

### Heartbeat Screenshots

**Purpose**: Heartbeat monitors the availability and uptime of HTTP endpoints (health checks).

**Images:**
- `heartbeat.png` - Heartbeat dashboard showing service availability status
- `heartbeat2.png` - Additional Heartbeat monitoring view (alternative dashboard or detailed metrics)

**What Heartbeat Monitors:**
- Frontend application availability
- API Gateway health endpoint
- All microservices health endpoints (Auth, Users, Gig, Chat, Order, Review, Notification)

**Configuration**: See `../jobber-elastic/heartbeat.yaml`

**How to View:**
1. Access Kibana dashboard
2. Navigate to **Observability > Uptime** or **Stack Monitoring**
3. View service availability and response times

---

### Metricbeat Screenshots

**Purpose**: Metricbeat collects system and Kubernetes metrics from nodes and pods.

**Images:**
- `metricbeat.png` - Metricbeat dashboard showing cluster metrics (CPU, memory, network, etc.)

**What Metricbeat Collects:**
- Node metrics (CPU, memory, disk, network)
- Pod metrics (resource usage per pod)
- Kubernetes cluster state (deployments, replicasets, services)
- Container metrics
- System-level metrics

**Configuration**: See `../jobber-elastic/metricbeat.yaml`

**How to View:**
1. Access Kibana dashboard
2. Navigate to **Observability > Metrics** or **Stack Monitoring**
3. View cluster and pod resource utilization

---

### Logs Screenshot

**Purpose**: Centralized logging visualization in Kibana.

**Images:**
- `logs.png` - Kibana logs dashboard showing application logs from all services

**What Logs Are Collected:**
- Application logs from all microservices
- Kubernetes pod logs
- System logs
- Error logs and stack traces

**How to View:**
1. Access Kibana dashboard
2. Navigate to **Analytics > Discover** or **Observability > Logs**
3. Filter and search logs by service, namespace, or time range

---

## 🔧 Setup

### Prerequisites

- Elasticsearch cluster deployed and accessible
- Kibana deployed and configured
- Heartbeat and Metricbeat deployed (see `../jobber-elastic/`)

### Accessing Dashboards

**Kibana URL**: Configured in your Elasticsearch deployment

**Default Dashboards:**
- **Uptime**: Service availability (Heartbeat)
- **Metrics**: Cluster and pod metrics (Metricbeat)
- **Logs**: Application and system logs

---

## 📝 Notes

- These screenshots are examples of what you should see when monitoring is properly configured
- Actual dashboards may vary depending on your Elastic Stack version and configuration
- For troubleshooting, see the [Troubleshooting Guide](../../../docs/troubleshooting/) in the main documentation

---

## 🔗 Related Documentation

- **Heartbeat Configuration**: `../jobber-elastic/heartbeat.yaml`
- **Metricbeat Configuration**: `../jobber-elastic/metricbeat.yaml`
- **Elastic Stack Setup**: See Elasticsearch and Kibana deployment configurations

---

**Note**: These images serve as reference documentation. Update them when making significant changes to monitoring configuration or dashboards.

