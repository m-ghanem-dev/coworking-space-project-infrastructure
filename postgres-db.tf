provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

# Deploy PostgreSQL Helm chart configured to use the existing PVC
resource "helm_release" "postgresql" {
  name       = "my-postgres"
  namespace  = "default"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = "16.3.0"
  wait       = false

  # https://github.com/bitnami/charts/blob/main/bitnami/postgresql/values.yaml
  set = [
    {
    # the chart does NOT create its own PVC and instead mounts the storage from your existing PVC.
      name  = "primary.persistence.existingClaim"
      value = kubernetes_persistent_volume_claim.postgres_pvc.metadata[0].name
    },
    # Helm chart uses the PVC as-is without trying to override or request dynamic storage.
    {
      name  = "primary.persistence.storageClass"
      value = ""
    },
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


# Create the EBS volume in AWS
resource "aws_ebs_volume" "postgres_volume" {
  availability_zone = "eu-central-1"  # must match your EKS node AZ
  size              = 20              # in GB
  type              = "gp2"
  tags = {
    Name = "terraform-postgres-ebs"
  }
}

# Create the Kubernetes PersistentVolume referencing the EBS volume
resource "kubernetes_persistent_volume" "postgres_pv" {
  metadata {
    name = "postgres-pv"
  }

  spec {
    capacity = {
      storage = "20Gi"
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = aws_ebs_volume.postgres_volume.id
        fs_type   = "ext4"
      }
    }

    storage_class_name              = "manual"
    persistent_volume_reclaim_policy = "Retain"
  }
}

# Create the PersistentVolumeClaim bound to the PV
resource "kubernetes_persistent_volume_claim" "postgres_pvc" {
  metadata {
    name      = "postgres-pvc"
    namespace = "default"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "20Gi"
      }
    }

    storage_class_name = "manual"
    volume_name        = kubernetes_persistent_volume.postgres_pv.metadata[0].name
  }
}

