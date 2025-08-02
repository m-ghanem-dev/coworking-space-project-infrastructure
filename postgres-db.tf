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

  set = [
    {
      name  = "postgresqlUsername"
      value = "myuser"
    },
    {
      name  = "postgresqlPassword"
      value = "mypassword"
    },
    {
      name  = "postgresqlDatabase"
      value = "mydatabase"
    },
    {
      name  = "service.type"
      value = "LoadBalancer"
    }
  ]
  depends_on = [module.eks]
}
