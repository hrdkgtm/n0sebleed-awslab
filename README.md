# EKS Terraform Project

This project provides Terraform configurations to create and manage an Amazon EKS cluster.

**Note:** All Terraform commands should be run from the `terraform/` directory.

## Prerequisites

- AWS CLI installed and configured
- Terraform installed
- AWS account with necessary permissions

## Setup

1. **Setup IAM Permissions:**
   
   Ensure your AWS IAM user has the following managed policies attached:
   - `AmazonEC2FullAccess`
   - `AmazonEKSClusterPolicy` 
   - `IAMFullAccess`
   - `CloudWatchLogsFullAccess`
   
   Or create a custom policy with the necessary permissions for EKS, EC2, IAM, and CloudWatch Logs operations.

2. **Configure AWS Credentials:**
   ```bash
   # Copy the environment template
   cp .env.template .env

   # Edit .env and fill in your AWS credentials
   # AWS_ACCESS_KEY_ID=your_key_here
   # AWS_SECRET_ACCESS_KEY=your_secret_here
   ```

3. **Load Environment Variables:**
   ```bash
   # Source the environment variables
   source ./env.sh
   ```

## Usage

### Create the EKS Cluster

1. Navigate to the terraform directory:
   ```bash
   cd terraform
   ```

2. Load environment variables (if not already loaded):
   ```bash
   source ../env.sh
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Plan the deployment:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

This will create:
- VPC with DNS support
- Public subnets (for NAT Gateways and Load Balancers)
- Private subnets (for EKS worker nodes)
- Internet Gateway
- NAT Gateways (one per AZ for high availability)
- EKS cluster with both public and private subnet access
- Managed node group in private subnets (more secure)

### Tear Down Node Groups

To tear down all node groups (including those not managed by Terraform), apply with the node group creation disabled:

1. Navigate to the terraform directory:
   ```bash
   cd terraform
   ```

2. Load environment variables (if not already loaded):
   ```bash
   source ../env.sh
   ```

3. Set the variable:
   ```bash
   terraform apply -var="create_node_group=false"
   ```

This will delete all existing node groups in the cluster.

### Destroy Everything

To destroy the entire cluster:
```bash
cd terraform
source ../env.sh
terraform destroy
```

## Variables

- `region`: AWS region (default: us-east-1)
- `cluster_name`: Name of the EKS cluster (default: n0sebleed-eks)
- `vpc_cidr`: CIDR for VPC (default: 10.0.0.0/16)
- `public_subnet_cidrs`: List of public subnet CIDRs (default: ["10.0.1.0/24", "10.0.2.0/24"])
- `private_subnet_cidrs`: List of private subnet CIDRs (default: ["10.0.101.0/24", "10.0.102.0/24"])
- `node_group_name`: Name of the node group
- `instance_types`: Instance types for nodes
- `desired_capacity`: Desired number of nodes
- `min_size`: Minimum number of nodes
- `max_size`: Maximum number of nodes
- `create_node_group`: Whether to create the node group (default: true)

## Outputs

- `cluster_endpoint`: EKS cluster endpoint
- `cluster_security_group_id`: Security group ID
- `vpc_id`: VPC ID
- `public_subnet_ids`: Public subnet IDs
- `private_subnet_ids`: Private subnet IDs
- `nat_gateway_ids`: NAT Gateway IDs