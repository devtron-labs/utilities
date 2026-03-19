# --- EKS Cluster ---
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  version  = var.eks_version
  role_arn = var.iam_role_arn

  vpc_config {
    subnet_ids              = concat(var.public_subnet_ids, var.private_subnet_ids)
    endpoint_public_access  = true
    endpoint_private_access = false
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]
}

# --- Launch Template ---
# This ensures Hop Limit 2 (for VPC-CNI/EBS CSI) and EBS Root Volume Encryption
resource "aws_launch_template" "eks_nodes" {
  name_prefix = "${var.cluster_name}-node-lt-"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" 
    http_put_response_hop_limit = 2 
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-node"
    }
  }
}

# --- Managed Node Group ---
resource "aws_eks_node_group" "default_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.nodegroup_desired_size
    min_size     = var.nodegroup_min_size
    max_size     = var.nodegroup_max_size
  }

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  instance_types = var.nodegroup_instance_types
  ami_type       = "AL2023_x86_64_STANDARD"
}

# --- EKS Addons ---

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "vpc-cni"
  depends_on   = [aws_eks_node_group.default_nodes]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "kube-proxy"
  depends_on   = [aws_eks_node_group.default_nodes]
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "coredns"
  addon_version               = "v1.12.3-eksbuild.1"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    tolerations = [
      {
        key      = "node.cloudprovider.kubernetes.io/uninitialized"
        operator = "Exists"
        effect   = "NoSchedule"
      },
      {
        key      = "node.kubernetes.io/not-ready"
        operator = "Exists"
        effect   = "NoSchedule"
      }
    ]
  })

  depends_on = [aws_eks_node_group.default_nodes]
}

# VALIDATED EBS CSI DRIVER (Merged and Corrected)
resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.eks.name # Changed .this to .eks to match resource above
  addon_name   = "aws-ebs-csi-driver"
  
  # Crucial for permissions
  service_account_role_arn = var.ebs_csi_role_arn 

  # Prevents the 409 "Already Exists" error
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  lifecycle {
    ignore_changes = [modified_at]
  }

  depends_on = [aws_eks_node_group.default_nodes]
}
# --- Outputs ---

output "oidc_url" {
  value = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.eks.name
}