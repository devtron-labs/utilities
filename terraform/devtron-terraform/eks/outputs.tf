output "eks_cluster_id" { value = aws_eks_cluster.eks.id }
output "eks_cluster_endpoint" { value = aws_eks_cluster.eks.endpoint }
output "eks_node_role_arn" { value = aws_eks_node_group.default_nodes.node_role_arn }