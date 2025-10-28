# Karpenter Setup for n0sebleed-awslab

This directory contains the Karpenter configuration for the n0sebleed EKS cluster, implementing automatic node provisioning and scaling.

## Overview

Karpenter is a Kubernetes node provisioner that automatically launches right-sized compute resources in response to changing application demand. This setup includes:

- **Karpenter Controller**: Deployed using Helm with v1.8.1
- **Node Pools**: Separate pools for different workload types
- **EC2 Node Classes**: Shared configuration for EC2 instances
- **Test Workloads**: Sample applications to demonstrate scaling behavior

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   workload-a    │    │   workload-b    │    │  general apps   │
│   (tainted)     │    │   (tainted)     │    │  (no taints)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │
        v                       v                       v
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ workload-a-pool │    │ workload-b-pool │    │  default-pool   │
│   dedicated     │    │   dedicated     │    │    shared       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │
        └───────────────────────┼───────────────────────┘
                                │
                                v
                    ┌─────────────────┐
                    │ default-nodeclass│
                    │  (shared EC2)   │
                    └─────────────────┘
```

## Files Description

### Core Configuration

| File | Description |
|------|-------------|
| `karpenter.yaml` | Main Karpenter controller deployment (Helm output) |
| `karpenter-nodepool.yaml` | Default node pool configuration |
| `workload-ab-nodepool.yaml` | Dedicated node pools for workload-a and workload-b |

### Environment Setup

| File | Description |
|------|-------------|
| `.env.template` | Template for environment variables |
| `.env` | Local environment configuration (gitignored) |

### State Files

| File | Description |
|------|-------------|
| `terraform.tfstate` | Terraform state for Karpenter resources |

## Quick Start

### 1. Prerequisites

Ensure you have:
- EKS cluster running (`n0sebleed-eks`)
- AWS CLI configured
- kubectl configured for your cluster
- Helm installed

### 2. Environment Setup

```bash
# Copy environment template
cp .env.template .env

# Edit .env with your AWS credentials and cluster details
# Set CLUSTER_NAME=n0sebleed-eks
```

### 3. Deploy Karpenter Controller

```bash
# Apply the Karpenter controller
kubectl apply -f karpenter.yaml

# Verify deployment
kubectl get pods -n kube-system -l app.kubernetes.io/name=karpenter
```

### 4. Deploy Node Pools

```bash
# Deploy default node pool
kubectl apply -f karpenter-nodepool.yaml

# Deploy workload-specific node pools
kubectl apply -f workload-ab-nodepool.yaml

# Verify node pools
kubectl get nodepools
```

## Node Pool Configuration

### Default Node Pool

- **Purpose**: General workloads without specific requirements
- **Instance Types**: t3.small
- **Capacity**: Mixed (on-demand + spot)
- **Limits**: 20 CPU, 40Gi memory
- **Consolidation**: WhenEmptyOrUnderutilized (30s)

### Workload-A Node Pool

- **Purpose**: Dedicated nodes for workload-a
- **Taints**: `workload=workload-a:NoSchedule`
- **Instance Types**: t3.small
- **Limits**: 20 CPU, 40Gi memory
- **Consolidation**: WhenEmptyOrUnderutilized (10s)

### Workload-B Node Pool

- **Purpose**: Dedicated nodes for workload-b
- **Taints**: `workload=workload-b:NoSchedule`
- **Instance Types**: t3.small
- **Limits**: 20 CPU, 40Gi memory
- **Consolidation**: WhenEmptyOrUnderutilized (10s)

## Testing Node Decommissioning

### Deploy Test Workloads

```bash
# Deploy workload-a (1 replica)
kubectl apply -f ../scaletest/workload-a-deployment.yaml

# Deploy workload-b (10 replicas)
kubectl apply -f ../scaletest/workload-b-deployment.yaml
```

### Monitor Node Provisioning

```bash
# Watch nodes being created
kubectl get nodes -w -l workload

# Check pod distribution
kubectl get pods -o wide
```

### Test Decommissioning

```bash
# Scale workload-b to 0
kubectl scale deployment workload-b --replicas=0

# Watch nodes being removed (should happen within ~10 seconds)
kubectl get nodes -w -l workload=workload-b
```

## Key Features Demonstrated

### 1. Workload Isolation
- **Taints and Tolerations**: Ensure workloads only run on designated nodes
- **Node Affinity**: Prefer specific node types for workloads
- **Separate Node Pools**: Independent scaling and lifecycle management

### 2. Efficient Resource Management
- **Fast Decommissioning**: Nodes removed within 10-30 seconds when empty
- **Mixed Instance Types**: Support for both on-demand and spot instances
- **Right-sizing**: Automatic selection of appropriate instance types

### 3. Cost Optimization
- **Spot Instance Support**: Reduce costs with spot instances
- **Aggressive Consolidation**: Quick cleanup of unused resources
- **Resource Limits**: Prevent runaway costs with pool limits

## Monitoring and Troubleshooting

### Check Karpenter Controller

```bash
# View controller logs
kubectl logs -n kube-system -l app.kubernetes.io/name=karpenter -f

# Check controller status
kubectl get deployment -n kube-system karpenter
```

### Monitor Node Pool Status

```bash
# List all node pools
kubectl get nodepools

# Describe specific node pool
kubectl describe nodepool workload-a-nodepool

# Check node claims
kubectl get nodeclaims
```

### View Node Labels and Taints

```bash
# Show nodes with workload labels
kubectl get nodes -l workload --show-labels

# Check specific node details
kubectl describe node <node-name>
```

### Useful Commands

```bash
# Get nodes by workload type
kubectl get nodes -l workload=workload-a
kubectl get nodes -l workload=workload-b

# Monitor pod scheduling
kubectl get events --sort-by='.lastTimestamp'

# Check Karpenter events
kubectl get events -n kube-system --field-selector involvedObject.name=karpenter
```

## Cleanup

### Remove Test Workloads

```bash
kubectl delete -f ../scaletest/workload-a-deployment.yaml
kubectl delete -f ../scaletest/workload-b-deployment.yaml
```

### Remove Node Pools

```bash
kubectl delete -f workload-ab-nodepool.yaml
kubectl delete -f karpenter-nodepool.yaml
```

### Remove Karpenter Controller

```bash
kubectl delete -f karpenter.yaml
```

## Configuration Details

### Node Class Features

- **AMI**: Latest Amazon Linux 2023 EKS-optimized
- **Instance Store**: RAID0 configuration when available
- **Security**: IMDSv2 required, security groups auto-discovered
- **Subnets**: Auto-discovered using `karpenter.sh/discovery` tag

### Disruption Settings

- **consolidationPolicy**: 
  - `WhenEmptyOrUnderutilized` for default pool (balanced)
  - `WhenEmptyOrUnderutilized` for workload pools (faster cleanup)
- **consolidateAfter**: 10-30 seconds depending on pool

## References

- **Based on**: [Karpenter Migration from CAS Guide](https://karpenter.sh/docs/getting-started/migrating-from-cas/)
- **Documentation**: [Karpenter Official Docs](https://karpenter.sh/)
- **AWS Guide**: [EKS Karpenter Guide](https://docs.aws.amazon.com/eks/latest/userguide/karpenter.html)