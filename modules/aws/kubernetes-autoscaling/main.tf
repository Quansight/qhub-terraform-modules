resource "kubernetes_service_account" "main" {
  metadata = {
    labels = {
      "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
      "k8s-app" = "cluster-autoscaler"
    }
    name = "cluster-autoscaler"
    namespace = "kube-system"
  }
}


resource "kubernetes_cluster_role" {
  metadata = {
    labels = {
      "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
      "k8s-app" = "cluster-autoscaler"
    }
    name = "cluster-autoscaler"
  }

  rule = [
    {
      apiGroups = [""]
      resources = ["events", "endpoints"]
      verbs = ["create", "patch"]
    },
    {
      apiGroups = [""]
      resources = ["pods/eviction"]
      verbs = ["create"]
    },
    {
      apiGroups = [""]
      resources = ["pods/status"]
      verbs = ["update"]
    },
    {
      apiGroups = [""]
      resources = ["endpoints"]
      resourceNames = ["cluster-autoscaler"]
      verbs = ["get", "update"]
    },
    {
      apiGroups = [""]
      resources = ["nodes"]
      verbs = ["watch", "list", "get", "update"]
    },
    {
      apiGroups = [""]
      resources = [
        "pods",
        "services",
        "replicationcontrollers",
        "persistentvolumeclaims",
        "persistentvolumes"
      ]
      verbs = ["watch", "list", "get"]
    },
    {
      apiGroups = ["extensions"]
      resources = ["replicasets", "daemonsets"]
      verbs = ["watch", "list", "get"]
    },
    {
      apiGroups = ["policy"]
      resources = ["poddisruptionbudgets"]
      verbs = ["watch", "list"]
    },
    {
      apiGroups = ["apps"]
      resources = ["statefulsets", "replicasets", "daemonsets"]
      verbs = ["watch", "list", "get"]
    },
    {
      apiGroups = ["storage.k8s.io"]
      resources = ["storageclasses", "csinodes"]
      verbs = ["watch", "list", "get"]
    },
    {
      apiGroups = ["batch", "extensions"]
      resources = ["jobs"]
      verbs = ["get", "list", "watch", "patch"]
    },
    {
      apiGroups = ["coordination.k8s.io"]
      resources = ["leases"]
      verbs = ["create"]
    },
    {
      apiGroups = ["coordination.k8s.io"]
      resourceNames = ["cluster-autoscaler"]
      resources = ["leases"]
      verbs = ["get", "update"]
    }
  ]
}


resource "kubernetes_role" {
  metadata = {
    name = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
      "k8s-app" = "cluster-autoscaler"
    }
  }

  rules = [
    {
      apiGroups = [""]
      resources = ["configmaps"]
      verbs = ["create","list","watch"]
    },
    {
      apiGroups = [""]
      resources = ["configmaps"]
      resourceNames = ["cluster-autoscaler-status", "cluster-autoscaler-priority-expander"]
      verbs = ["delete", "get", "update", "watch"]
    }
  ]
}

resource "kuberentes_cluster_role_binding" {
  metadata = {
    name = "cluster-autoscaler"
    labels = {
      "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
      "k8s-app" = "cluster-autoscaler"
    }
  }

  roleRef = {
    apiGroup = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-autoscaler"
  }

  subjects = [
    {
      kind = "ServiceAccount"
      name = "cluster-autoscaler"
      namespace = "kube-system"
    }
  ]
}

resource "kubernetes_role_binding" "main" {
  metadata = {
    name = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      "k8s-addon" = "cluster-autoscaler.addons.k8s.io"
      "k8s-app" = "cluster-autoscaler"
    }
  }

  roleRef = {
    apiGroup = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "cluster-autoscaler"
  }

  subjects = [
    {
      kind = "ServiceAccount"
      name = "cluster-autoscaler"
      namespace = "kube-system"
    }
  ]
}


resource "kubernetes_deployment" {
  metadata = {
    name = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      app = "cluster-autoscaler"
    }
  }

  spec = {
    replicas = 1
    selector = {
      matchLabels = {
        app = "cluster-autoscaler"
      }
    }
    template = {
      metadata = {
        labels = {
          app = "cluster-autoscaler"
        }
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port" = "8085"
        }
        spec = {
          serviceAccountName = "cluster-autoscaler"
          containers = [
            {
              image = "k8s.gcr.io/cluster-autoscaler:v1.12.3"
              name = "cluster-autoscaler"
              resources = {
                limits = {
                  cpu = "100m"
                  memory = "300Mi"
                }
                requests = {
                  cpu = "100m"
                  memory = "300Mi"
                }
              }
              command = [
                "./cluster-autoscaler",
                "--v=4",
                "--stderrthreshold=info",
                "--cloud-provider=aws",
                "--skip-nodes-with-local-storage=false",
                "--expander=least-waste",
                "--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${var.cluster_name}"
              ]
              volumeMounts = [
                {
                  name = "ssl-certs"
                  mountPath = "/etc/ssl/certs/ca-certificates.crt"
                  readOnly = true
                }
              ]
              imagePullPolicy = "Always"
            }
          ]

          volumes = [
            {
              name = "ssl-certs"
              hostPath = {
                path = "/etc/ssl/certs/ca-bundle.crt"
              }
            }
          ]
        }
      }
    }
  }
}
