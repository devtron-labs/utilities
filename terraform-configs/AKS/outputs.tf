output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}
output "cluster_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}
# Get your kubeconfig file in file named config in current directory
resource "local_file" "kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.aks_cluster]
  filename     = "./config"
  content      = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
}

output "aks_host" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.host
  sensitive = true
}
