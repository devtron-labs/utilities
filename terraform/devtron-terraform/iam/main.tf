# --- Data Sources ---
data "aws_caller_identity" "current" {}

# -------------------------------------------------------------------
# 1. THE SHARED NODE & CLUSTER ROLE (Devtron)
# -------------------------------------------------------------------
resource "aws_iam_role" "devtron_custom_role" {
  name = "${var.role_name}-${terraform.workspace}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { 
        Effect = "Allow", 
        Principal = { Service = "eks.amazonaws.com" }, 
        Action = "sts:AssumeRole" 
      },
      { 
        Effect = "Allow", 
        Principal = { Service = "ec2.amazonaws.com" }, 
        Action = "sts:AssumeRole" 
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.devtron_custom_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "node_policy" {
  role       = aws_iam_role.devtron_custom_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.devtron_custom_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.devtron_custom_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# -------------------------------------------------------------------
# 2. EBS CSI IRSA ROLE
# -------------------------------------------------------------------
resource "aws_iam_role" "ebs_csi_irsa_role" {
  name = "devtron-ebs-csi-role-${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Federated = var.oidc_arn }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(var.oidc_url, "https://", "")}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa",
          "${replace(var.oidc_url, "https://", "")}:aud": "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attach" {
  role       = aws_iam_role.ebs_csi_irsa_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# -------------------------------------------------------------------
# 3. KARPENTER CONTROLLER ROLE (IRSA) - Suffix: -devtron
# -------------------------------------------------------------------
resource "aws_iam_role" "karpenter_controller" {
  name = "karpenter-controller-${var.cluster_name}-devtron"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = { Federated = var.oidc_arn }
      Condition = {
        StringEquals = {
          "${replace(var.oidc_url, "https://", "")}:sub": "system:serviceaccount:karpenter:karpenter",
          "${replace(var.oidc_url, "https://", "")}:aud": "sts.amazonaws.com"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "karpenter_controller_policy" {
  name = "KarpenterControllerPolicy-devtron"
  role = aws_iam_role.karpenter_controller.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateTags",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSubnets",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "iam:PassRole",
          "iam:ListInstanceProfiles",
          "iam:CreateInstanceProfile",
          "iam:TagInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:GetInstanceProfile",
          "ssm:GetParameter",
          "pricing:GetProducts"
     
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "iam:PassRole"
        Effect   = "Allow"
        Resource = aws_iam_role.karpenter_node_role.arn
      },
      {
        Action   = "eks:DescribeCluster"
        Effect   = "Allow"
        Resource = "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster_name}"
      }
    ]
  })
}

# -------------------------------------------------------------------
# 4. KARPENTER NODE ROLE (EC2) - Suffix: -devtron
# -------------------------------------------------------------------
resource "aws_iam_role" "karpenter_node_role" {
  name = "KarpenterNodeRole-${var.cluster_name}-devtron"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_node_WorkerNodePolicy" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_CNI_Policy" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_RegistryPolicy" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "karpenter_node_SSM" {
  role       = aws_iam_role.karpenter_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "karpenter_node_profile" {
  name = "KarpenterNodeInstanceProfile-${var.cluster_name}-devtron"
  role = aws_iam_role.karpenter_node_role.name
}