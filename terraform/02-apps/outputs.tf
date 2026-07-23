output "argocd_namespace" {
  value       = helm_release.argocd.namespace
  description = "Namespace onde o Argo CD foi instalado"
}

output "get_argocd_password_command" {
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
  description = "Comando para recuperar a senha inicial do admin do Argo CD"
}

output "argocd_server_url" {
  value       = "https://${data.kubernetes_service.argocd_server_status.status[0].load_balancer[0].ingress[0].ip}:443"
  description = "URL do servidor Argo CD"
}

output "argocd_server_ip" {
  value = data.kubernetes_service.argocd_server_status.status[0].load_balancer[0].ingress[0].ip
}