provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "postgresql" {
  name       = "my-postgres"
  namespace  = "default"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "15.5.2"

  set {
    name  = "postgresqlUsername"
    value = "myuser"
  }

  set {
    name  = "postgresqlPassword"
    value = "mypassword"
  }

  set {
    name  = "postgresqlDatabase"
    value = "mydatabase"
  }

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
}
