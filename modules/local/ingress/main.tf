resource "null_resource" "dependency_getter" {
  triggers = {
    my_dependencies = join(",", var.dependencies)
  }
}

resource "kubernetes_namespace" "namespace_ingress_nginx" {
  metadata {
    labels = {
      "app.kubernetes.io/instance" = "ingress-nginx"
      "app.kubernetes.io/name"     = "ingress-nginx"
    }
    name = "ingress-nginx"
  }
  depends_on = [
    null_resource.dependency_getter
  ]
}

resource "kubernetes_service_account" "serviceaccount_ingress_nginx" {
  metadata {
    labels = {
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name      = "ingress-nginx"
    namespace = "ingress-nginx"
  }
  depends_on = [
    kubernetes_namespace.namespace_ingress_nginx,
  ]
  automount_service_account_token = true
}

resource "kubernetes_validating_webhook_configuration" "validatingwebhookconfiguration_ingress_nginx_admission" {
  metadata {
    labels = {
      "app.kubernetes.io/component"  = "admission-webhook"
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name = "ingress-nginx-admission"
  }
  webhook {
    admission_review_versions = [
      "v1",
      "v1beta1",
    ]
    client_config {
      service {
        name      = "ingress-nginx-controller-admission"
        namespace = "ingress-nginx"
        path      = "/networking/v1beta1/ingresses"
      }
    }
    failure_policy = "Fail"
    match_policy   = "Equivalent"
    name           = "validate.nginx.ingress.kubernetes.io"
    rule {
      api_groups = [
        "networking.k8s.io",
      ]
      api_versions = [
        "v1beta1",
      ]
      operations = [
        "CREATE",
        "UPDATE",
      ]
      resources = [
        "ingresses",
      ]
    }
    side_effects = "None"
  }
  depends_on = [kubernetes_namespace.namespace_ingress_nginx]
}

resource "kubernetes_service_account" "serviceaccount_ingress_nginx_admission" {
  metadata {
    annotations = {
      "helm.sh/hook"               = "pre-install,pre-upgrade,post-install,post-upgrade"
      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
    labels = {
      "app.kubernetes.io/component"  = "admission-webhook"
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name      = "ingress-nginx-admission"
    namespace = "ingress-nginx"
  }
  depends_on = [
    kubernetes_namespace.namespace_ingress_nginx,
  ]
  automount_service_account_token = true
}

resource "kubernetes_cluster_role" "clusterrole_ingress_nginx_admission" {
  metadata {
    annotations = {
      "helm.sh/hook"               = "pre-install,pre-upgrade,post-install,post-upgrade"
      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
    labels = {
      "app.kubernetes.io/component"  = "admission-webhook"
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name = "ingress-nginx-admission"
  }
  rule {
    api_groups = [
      "admissionregistration.k8s.io",
    ]
    resources = [
      "validatingwebhookconfigurations",
    ]
    verbs = [
      "get",
      "update"
    ]
  }
  depends_on = [kubernetes_namespace.namespace_ingress_nginx]
}

resource "kubernetes_cluster_role_binding" "clusterrolebinding_ingress_nginx_admission" {
  metadata {
    annotations = {
      "helm.sh/hook"               = "pre-install,pre-upgrade,post-install,post-upgrade"
      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
    labels = {
      "app.kubernetes.io/component"  = "admission-webhook"
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name = "ingress-nginx-admission"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ingress-nginx-admission"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "ingress-nginx-admission"
    namespace = "ingress-nginx"
  }
  depends_on = [
    kubernetes_cluster_role.clusterrole_ingress_nginx_admission,
    kubernetes_service_account.serviceaccount_ingress_nginx_admission,
  ]
}

resource "kubernetes_role" "role_ingress_nginx_admission" {
  metadata {
    annotations = {
      "helm.sh/hook"               = "pre-install,pre-upgrade,post-install,post-upgrade"
      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
    labels = {
      "app.kubernetes.io/component"  = "admission-webhook"
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name      = "ingress-nginx-admission"
    namespace = "ingress-nginx"
  }
  rule {
    api_groups = [
      ""
    ]
    resources = [
      "secrets"
    ]
    verbs = [
      "get",
      "create"
    ]
  }
  depends_on = [kubernetes_namespace.namespace_ingress_nginx]
}

resource "kubernetes_role_binding" "rolebinding_ingress_nginx_admission" {
  metadata {
    annotations = {
      "helm.sh/hook"               = "pre-install,pre-upgrade,post-install,post-upgrade"
      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
    labels = {
      "app.kubernetes.io/component"  = "admission-webhook"
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name      = "ingress-nginx-admission"
    namespace = "ingress-nginx"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "ingress-nginx-admission"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "ingress-nginx-admission"
    namespace = "ingress-nginx"
  }
  depends_on = [
    kubernetes_role.role_ingress_nginx_admission,
    kubernetes_service_account.serviceaccount_ingress_nginx_admission,
  ]
}

resource "kubernetes_job" "job_ingress_nginx_admission_create" {
  metadata {
    annotations = {
      "helm.sh/hook"               = "pre-install,pre-upgrade"
      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
    labels = {
      "app.kubernetes.io/component"  = "admission-webhook"
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name      = "ingress-nginx-admission-create"
    namespace = "ingress-nginx"
  }
  spec {
    template {
      metadata {
        labels = {
          "app.kubernetes.io/component"  = "admission-webhook"
          "app.kubernetes.io/instance"   = "ingress-nginx"
          "app.kubernetes.io/managed-by" = "Helm"
          "app.kubernetes.io/name"       = "ingress-nginx"
          "app.kubernetes.io/version"    = "0.41.2"
          "helm.sh/chart"                = "ingress-nginx-3.10.1"
        }
        name = "ingress-nginx-admission-create"
      }
      spec {
        automount_service_account_token = true
        container {
          args = [
            "create",
            "--host=ingress-nginx-controller-admission,ingress-nginx-controller-admission.$(POD_NAMESPACE).svc",
            "--namespace=$(POD_NAMESPACE)",
            "--secret-name=ingress-nginx-admission",
          ]
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          image             = "docker.io/jettech/kube-webhook-certgen:v1.5.1"
          image_pull_policy = "IfNotPresent"
          name              = "create"
        }
        restart_policy = "OnFailure"
        security_context {
          run_as_non_root = true
          run_as_user     = 2000
        }
        service_account_name = "ingress-nginx-admission"
      }
    }
    backoff_limit = 2
  }
  depends_on = [
    kubernetes_service_account.serviceaccount_ingress_nginx_admission,
    kubernetes_role_binding.rolebinding_ingress_nginx_admission,
    kubernetes_cluster_role_binding.clusterrolebinding_ingress_nginx_admission,
  ]
  wait_for_completion = true
}

resource "kubernetes_job" "job_ingress_nginx_admission_patch" {
  metadata {
    annotations = {
      "helm.sh/hook"               = "post-install,post-upgrade"
      "helm.sh/hook-delete-policy" = "before-hook-creation,hook-succeeded"
    }
    labels = {
      "app.kubernetes.io/component"  = "admission-webhook"
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name      = "ingress-nginx-admission-patch"
    namespace = "ingress-nginx"
  }
  spec {
    template {
      metadata {
        labels = {
          "app.kubernetes.io/component"  = "admission-webhook"
          "app.kubernetes.io/instance"   = "ingress-nginx"
          "app.kubernetes.io/managed-by" = "Helm"
          "app.kubernetes.io/name"       = "ingress-nginx"
          "app.kubernetes.io/version"    = "0.41.2"
          "helm.sh/chart"                = "ingress-nginx-3.10.1"
        }
        name = "ingress-nginx-admission-patch"
      }
      spec {
        automount_service_account_token = true
        container {
          args = [
            "patch",
            "--webhook-name=ingress-nginx-admission",
            "--namespace=$(POD_NAMESPACE)",
            "--patch-mutating=false",
            "--secret-name=ingress-nginx-admission",
            "--patch-failure-policy=Fail",
          ]
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          image             = "docker.io/jettech/kube-webhook-certgen:v1.5.1"
          image_pull_policy = "IfNotPresent"
          name              = "patch"
        }
        restart_policy = "OnFailure"
        security_context {
          run_as_non_root = true
          run_as_user     = 2000
        }
        service_account_name = "ingress-nginx-admission"
      }
    }
  }
  depends_on = [
    kubernetes_service_account.serviceaccount_ingress_nginx_admission,
    kubernetes_job.job_ingress_nginx_admission_create,
  ]
  wait_for_completion = true
}

resource "kubernetes_config_map" "configmap_ingress_nginx_controller" {
  data = null
  metadata {
    labels = {
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [kubernetes_namespace.namespace_ingress_nginx]
}

resource "kubernetes_cluster_role" "clusterrole_ingress_nginx" {
  metadata {
    labels = {
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name = "ingress-nginx"
  }
  rule {
    api_groups = [
      "",
    ]
    resources = [
      "configmaps",
      "endpoints",
      "nodes",
      "pods",
      "secrets",
    ]
    verbs = [
      "list",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "",
    ]
    resources = [
      "nodes",
    ]
    verbs = [
      "get",
    ]
  }
  rule {
    api_groups = [
      "",
    ]
    resources = [
      "services",
    ]
    verbs = [
      "get",
      "list",
      "update",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "extensions",
      "networking.k8s.io",
    ]
    resources = [
      "ingresses",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "",
    ]
    resources = [
      "events",
    ]
    verbs = [
      "create",
      "patch",
    ]
  }
  rule {
    api_groups = [
      "extensions",
      "networking.k8s.io",
    ]
    resources = [
      "ingresses/status",
    ]
    verbs = [
      "update",
    ]
  }
  rule {
    api_groups = [
      "networking.k8s.io",
    ]
    resources = [
      "ingressclasses",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
  depends_on = [kubernetes_namespace.namespace_ingress_nginx]
}

resource "kubernetes_cluster_role_binding" "clusterrolebinding_ingress_nginx" {
  metadata {
    labels = {
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name = "ingress-nginx"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ingress-nginx"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "ingress-nginx"
    namespace = "ingress-nginx"
  }
  depends_on = [
    kubernetes_cluster_role.clusterrole_ingress_nginx,
    kubernetes_service_account.serviceaccount_ingress_nginx,
  ]
}

resource "kubernetes_role" "role_ingress_nginx" {
  metadata {
    labels = {
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name      = "ingress-nginx"
    namespace = "ingress-nginx"
  }
  rule {
    api_groups = [
      "",
    ]
    resources = [
      "namespaces",
    ]
    verbs = [
      "get",
    ]
  }
  rule {
    api_groups = [
      "",
    ]
    resources = [
      "configmaps",
      "pods",
      "secrets",
      "endpoints",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "",
    ]
    resources = [
      "services",
    ]
    verbs = [
      "get",
      "list",
      "update",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "extensions",
      "networking.k8s.io",
    ]
    resources = [
      "ingresses",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "extensions",
      "networking.k8s.io",
    ]
    resources = [
      "ingresses/status",
    ]
    verbs = [
      "update",
    ]
  }
  rule {
    api_groups = [
      "networking.k8s.io",
    ]
    resources = [
      "ingressclasses",
    ]
    verbs = [
      "get",
      "list",
      "watch",
    ]
  }
  rule {
    api_groups = [
      "",
    ]
    resource_names = [
      "ingress-controller-leader-nginx",
    ]
    resources = [
      "configmaps",
    ]
    verbs = [
      "get",
      "update",
    ]
  }
  rule {
    api_groups = [
      "",
    ]
    resources = [
      "configmaps",
    ]
    verbs = [
      "create",
    ]
  }
  rule {
    api_groups = [
      "",
    ]
    resources = [
      "endpoints",
    ]
    verbs = [
      "create",
      "get",
      "update",
    ]
  }
  rule {
    api_groups = [
      "",
    ]
    resources = [
      "events",
    ]
    verbs = [
      "create",
      "patch",
    ]
  }
  depends_on = [kubernetes_namespace.namespace_ingress_nginx]
}

resource "kubernetes_role_binding" "rolebinding_ingress_nginx" {
  metadata {
    labels = {
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name      = "ingress-nginx"
    namespace = "ingress-nginx"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "ingress-nginx"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "ingress-nginx"
    namespace = "ingress-nginx"
  }
  depends_on = [
    kubernetes_role.role_ingress_nginx,
    kubernetes_service_account.serviceaccount_ingress_nginx,
  ]
}

resource "kubernetes_service" "service_ingress_nginx_controller_admission" {
  metadata {
    labels = {
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name      = "ingress-nginx-controller-admission"
    namespace = "ingress-nginx"
  }
  spec {
    port {
      name        = "https-webhook"
      port        = 443
      target_port = "webhook"
    }
    selector = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/instance"  = "ingress-nginx"
      "app.kubernetes.io/name"      = "ingress-nginx"
    }
    type = "ClusterIP"
  }
  depends_on = [
    kubernetes_cluster_role_binding.clusterrolebinding_ingress_nginx_admission,
    kubernetes_role_binding.rolebinding_ingress_nginx_admission,
  ]
}

resource "kubernetes_service" "service_ingress_nginx_controller" {
  metadata {
    annotations = null
    labels = {
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  spec {
    port {
      name        = "http"
      port        = 80
      protocol    = "TCP"
      target_port = "http"
    }
    port {
      name        = "https"
      port        = 443
      protocol    = "TCP"
      target_port = "https"
    }
    selector = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/instance"  = "ingress-nginx"
      "app.kubernetes.io/name"      = "ingress-nginx"
    }
    type = "NodePort"
  }
  depends_on = [
    kubernetes_config_map.configmap_ingress_nginx_controller,
    kubernetes_service.service_ingress_nginx_controller_admission,
  ]
}

resource "kubernetes_deployment" "deployment_ingress_nginx_controller" {
  metadata {
    labels = {
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/instance"   = "ingress-nginx"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "ingress-nginx"
      "app.kubernetes.io/version"    = "0.41.2"
      "helm.sh/chart"                = "ingress-nginx-3.10.1"
    }
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  spec {
    min_ready_seconds      = 0
    revision_history_limit = 10
    selector {
      match_labels = {
        "app.kubernetes.io/component" = "controller"
        "app.kubernetes.io/instance"  = "ingress-nginx"
        "app.kubernetes.io/name"      = "ingress-nginx"
      }
    }
    strategy {
      rolling_update {
        max_unavailable = 1
      }
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/component" = "controller"
          "app.kubernetes.io/instance"  = "ingress-nginx"
          "app.kubernetes.io/name"      = "ingress-nginx"
        }
      }
      spec {
        automount_service_account_token = true
        container {
          args = [
            "/nginx-ingress-controller",
            "--election-id=ingress-controller-leader",
            "--ingress-class=nginx",
            "--configmap=$(POD_NAMESPACE)/ingress-nginx-controller",
            "--validating-webhook=:8443",
            "--validating-webhook-certificate=/usr/local/certificates/cert",
            "--validating-webhook-key=/usr/local/certificates/key",
            "--publish-status-address=localhost",
          ]
          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          env {
            name  = "LD_PRELOAD"
            value = "/usr/local/lib/libmimalloc.so"
          }
          image             = "k8s.gcr.io/ingress-nginx/controller:v0.41.2@sha256:1f4f402b9c14f3ae92b11ada1dfe9893a88f0faeb0b2f4b903e2c67a0c3bf0de"
          image_pull_policy = "IfNotPresent"
          lifecycle {
            pre_stop {
              exec {
                command = [
                  "/wait-shutdown",
                ]
              }
            }
          }
          liveness_probe {
            failure_threshold = 5
            http_get {
              path   = "/healthz"
              port   = 10254
              scheme = "HTTP"
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 1
          }
          name = "controller"
          port {
            container_port = 80
            host_port      = 80
            name           = "http"
            protocol       = "TCP"
          }
          port {
            container_port = 443
            host_port      = 443
            name           = "https"
            protocol       = "TCP"
          }
          port {
            container_port = 8443
            name           = "webhook"
            protocol       = "TCP"
          }
          readiness_probe {
            failure_threshold = 3
            http_get {
              path   = "/healthz"
              port   = 10254
              scheme = "HTTP"
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 1
          }
          resources {
            requests {
              cpu    = "100m"
              memory = "90Mi"
            }
          }
          security_context {
            allow_privilege_escalation = true
            capabilities {
              add = [
                "NET_BIND_SERVICE",
              ]
              drop = [
                "ALL",
              ]
            }
            run_as_user = 101
          }
          volume_mount {
            mount_path = "/usr/local/certificates/"
            name       = "webhook-cert"
            read_only  = true
          }
        }
        dns_policy = "ClusterFirst"
        node_selector = {
          "ingress-ready"    = "true"
          "kubernetes.io/os" = "linux"
        }
        service_account_name             = "ingress-nginx"
        termination_grace_period_seconds = 0
        toleration {
          effect   = "NoSchedule"
          key      = "node-role.kubernetes.io/master"
          operator = "Equal"
        }
        volume {
          name = "webhook-cert"
          secret {
            secret_name = "ingress-nginx-admission"
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_job.job_ingress_nginx_admission_create,
    kubernetes_job.job_ingress_nginx_admission_patch,
  ]
}
