output "aks_id" {
  description = "The ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_fqdn" {
  description = "The FQDN of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "aks_node_resource_group" {
  description = "The auto-generated resource group which contains the resources for the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "aks_kube_config" {
  description = "The raw kube config for the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "aks_identity_principal_id" {
  description = "The principal ID of the system assigned identity of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

output "aks_oidc_issuer_url" {
  description = "The OIDC issuer URL of the AKS cluster (only set when oidc_issuer_enabled is true)."
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

output "aks_kubelet_identity_object_id" {
  description = "The object ID of the kubelet managed identity of the AKS cluster."
  value       = try(azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id, null)
}
