provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "postgresql" {
  name       = "my-postgres"
  namespace  = "default"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "15.5.2"
  wait       = false

  set {
    name  = "auth.username"
    value = "myuser"
  }

  set {
    name  = "auth.password"
    value = "mypassword"
  }

  set {
    name  = "auth.database"
    value = "mydatabase"
  }

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  depends_on = [module.eks]
}
