output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = aws_iam_role.eks_cluster_role.name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN associated with EKS cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "node_group_iam_role_name" {
  description = "IAM role name associated with EKS node group"
  value       = aws_iam_role.eks_node_role.name
}

output "node_group_iam_role_arn" {
  description = "IAM role ARN associated with EKS node group"
  value       = aws_iam_role.eks_node_role.arn
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.eks_vpc.id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  description = "Private Subnet IDs"
  value       = aws_subnet.private_subnets[*].id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = aws_nat_gateway.eks_nat[*].id
}