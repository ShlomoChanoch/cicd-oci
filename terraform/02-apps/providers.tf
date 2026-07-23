terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "oci" {
  config_file_profile = "DEFAULT"
  region              = var.region
}

data "terraform_remote_state" "infra" {
  backend = "local"
  config = {
    path = "../01-infra/terraform.tfstate"
  }
}

data "oci_containerengine_cluster_kube_config" "oke_kubeconfig" {
  cluster_id = data.terraform_remote_state.infra.outputs.cluster_id
}

locals {
  kubeconfig = yamldecode(data.oci_containerengine_cluster_kube_config.oke_kubeconfig.content)
}

provider "kubernetes" {
  host                   = local.kubeconfig.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "oci"
    args        = ["ce", "cluster", "generate-token", "--cluster-id", data.terraform_remote_state.infra.outputs.cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = local.kubeconfig.clusters[0].cluster.server
    cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "oci"
      args        = ["ce", "cluster", "generate-token", "--cluster-id", data.terraform_remote_state.infra.outputs.cluster_id]
    }
  }
}