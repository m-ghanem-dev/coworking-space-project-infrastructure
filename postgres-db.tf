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

  # https://github.com/bitnami/charts/blob/main/bitnami/postgresql/values.yaml
  set = [
    {
      name  = "auth.username"
      value = "myuser"
    },
    {
      name  = "auth.password"
      value = "mypassword"
    },
    {
      name  = "auth.database"
      value = "mydatabase"
    },
    {
      name  = "primary.service.type"
      value = "LoadBalancer"
    }
  ]

  depends_on = [module.eks]
}
