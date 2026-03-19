output "devtron_custom_role_arn" { value = aws_iam_role.devtron_custom_role.arn }
output "eks_node_role_arn"      { value = aws_iam_role.devtron_custom_role.arn }
output "ebs_csi_role_arn"       { value = aws_iam_role.ebs_csi_irsa_role.arn }
output "karpenter_controller_role_arn" { value = aws_iam_role.karpenter_controller.arn }
output "karpenter_node_role_name"      { value = aws_iam_role.karpenter_node_role.name }