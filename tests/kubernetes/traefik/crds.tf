resource "kubernetes_manifest" "ingress_route" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1beta1"
    kind = "CustomResourceDefinition"
    metadata = {
      name = "ingressroutes.traefik.containo.us"
    }
    spec = {
      group = "traefik.containo.us"
      version = "v1alpha1"
      names = {
        kind = "IngressRoute"
        plural = "ingressroutes"
        singular = "ingressroute"
      }
      scope = "Namespaced"
    }
  }
}


resource "kubernetes_manifest" "ingress_route_tcp" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1beta1"
    kind = "CustomResourceDefinition"
    metadata = {
      name = "ingressroutes.traefik.containo.us"
    }
    spec = {
      group = "traefik.containo.us"
      version = "v1alpha1"
      names = {
        kind = "IngressRouteTCP"
        plural = "ingressroutetcps"
        singular = "ingressroutetcp"
      }
      scope = "Namespaced"
    }
  }
}


resource "kubernetes_manifest" "middleware" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1beta1"
    kind = "CustomResourceDefinition"
    metadata = {
      name = "ingressroutes.traefik.containo.us"
    }
    spec = {
      group = "traefik.containo.us"
      version = "v1alpha1"
      names = {
        kind = "Middleware"
        plural = "middlewares"
        singular = "middleware"
      }
      scope = "Namespaced"
    }
  }
}


resource "kubernetes_manifest" "tls_option" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1beta1"
    kind = "CustomResourceDefinition"
    metadata = {
      name = "ingressroutes.traefik.containo.us"
    }
    spec = {
      group = "traefik.containo.us"
      version = "v1alpha1"
      names = {
        kind = "TLSOption"
        plural = "tlsoptions"
        singular = "tlsoption"
      }
      scope = "Namespaced"
    }
  }
}


resource "kubernetes_manifest" "traefik_service" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1beta1"
    kind = "CustomResourceDefinition"
    metadata = {
      name = "ingressroutes.traefik.containo.us"
    }
    spec = {
      group = "traefik.containo.us"
      version = "v1alpha1"
      names = {
        kind = "TraefikService"
        plural = "traefikservices"
        singular = "traefikservice"
      }
      scope = "Namespaced"
    }
  }
}
