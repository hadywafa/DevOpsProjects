resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# nginx-ingress-controller — exposes services via an Azure LoadBalancer
resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.nginx_ingress_chart_version
  namespace        = kubernetes_namespace.ingress_nginx.metadata[0].name
  create_namespace = false  # namespace created above via kubernetes_namespace
  atomic           = true   # rolls back automatically on failure
  cleanup_on_fail  = true
  timeout          = 300

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    value = "/healthz"
  }

  set {
    name  = "controller.replicaCount"
    value = "2"
  }

  set {
    name  = "controller.nodeSelector.agentpool"
    value = "user"
  }
}

# cert-manager — issues and renews TLS certificates via Let's Encrypt (or self-signed)
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_chart_version
  namespace        = kubernetes_namespace.cert_manager.metadata[0].name
  create_namespace = false
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 300

  # Install CRDs required by cert-manager
  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "nodeSelector.agentpool"
    value = "user"
  }
}
