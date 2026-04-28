output "nginx_ingress_namespace" {
  value = kubernetes_namespace.ingress_nginx.metadata[0].name
}

output "nginx_ingress_release_name" {
  value = helm_release.nginx_ingress.name
}

output "cert_manager_namespace" {
  value = kubernetes_namespace.cert_manager.metadata[0].name
}

output "cert_manager_release_name" {
  value = helm_release.cert_manager.name
}
