resource "kubernetes_service_account" "main" {
  metadata {
    name      = "${var.name}-traefik"
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role" "main" {
  metadata {
    name = "${var.name}-traefik"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints", "secrets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }

  rule {
    api_groups = ["traefik.containo.us"]
    resources  = ["ingressroutes", "ingressroutetcps", "middlewares", "tlsoptions", "traefikservices"]
    verbs      = ["get", "list", "watch"]
  }
}


resource "kubernetes_cluster_role_binding" "main" {
  metadata {
    name = "${var.name}-traefik"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.main.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.main.metadata.0.name
    namespace = var.namespace
  }
}
