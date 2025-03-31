output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}
output "cluster_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}
output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  sensitive = true
}
output "aks_host" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.host
  sensitive = true
}
