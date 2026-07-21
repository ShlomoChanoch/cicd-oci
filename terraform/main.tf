resource "oci_core_vcn" "generated_oci_core_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "oke-vcn-quick-cluster1-a081805fa"
  dns_label      = "cluster1"
}

resource "oci_core_internet_gateway" "generated_oci_core_internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "oke-igw-quick-cluster1-a081805fa"
  enabled        = "true"
  vcn_id         = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_core_subnet" "service_lb_subnet" {
  cidr_block                 = "10.0.20.0/24"
  compartment_id             = var.compartment_ocid
  display_name               = "oke-svclbsubnet-quick-cluster1-a081805fa-regional"
  dns_label                  = "lbsubd68529ff0"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_default_route_table.generated_oci_core_default_route_table.id
  security_list_ids          = ["${oci_core_vcn.generated_oci_core_vcn.default_security_list_id}"]
  vcn_id                     = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_core_subnet" "node_subnet" {
  cidr_block                 = "10.0.10.0/24"
  compartment_id             = var.compartment_ocid
  display_name               = "oke-nodesubnet-quick-cluster1-a081805fa-regional"
  dns_label                  = "sub4efee855c"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_default_route_table.generated_oci_core_default_route_table.id
  security_list_ids          = ["${oci_core_security_list.node_sec_list.id}"]
  vcn_id                     = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_core_subnet" "kubernetes_api_endpoint_subnet" {
  cidr_block                 = "10.0.0.0/28"
  compartment_id             = var.compartment_ocid
  display_name               = "oke-k8sApiEndpoint-subnet-quick-cluster1-a081805fa-regional"
  dns_label                  = "suba500f202c"
  prohibit_public_ip_on_vnic = "false"
  route_table_id             = oci_core_default_route_table.generated_oci_core_default_route_table.id
  security_list_ids          = ["${oci_core_security_list.kubernetes_api_endpoint_sec_list.id}"]
  vcn_id                     = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_core_default_route_table" "generated_oci_core_default_route_table" {
  display_name = "oke-public-routetable-cluster1-a081805fa"
  route_rules {
    description       = "traffic to/from internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.generated_oci_core_internet_gateway.id
  }
  manage_default_resource_id = oci_core_vcn.generated_oci_core_vcn.default_route_table_id
}

resource "oci_core_security_list" "service_lb_sec_list" {
  compartment_id = var.compartment_ocid
  display_name   = "oke-svclbseclist-quick-cluster1-a081805fa"
  vcn_id         = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_core_security_list" "node_sec_list" {
  compartment_id = var.compartment_ocid
  display_name   = "oke-nodeseclist-quick-cluster1-a081805fa"
  egress_security_rules {
    description      = "Allow pods on one worker node to communicate with pods on other worker nodes"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Access to Kubernetes API Endpoint"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Kubernetes worker to control plane communication"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = "10.0.0.0/28"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
    destination      = "all-iad-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "ICMP Access from Kubernetes Control Plane"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  egress_security_rules {
    description      = "Worker Nodes access to Internet"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }
  ingress_security_rules {
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
    protocol    = "all"
    source      = "10.0.10.0/24"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Path discovery"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    source    = "10.0.0.0/28"
    stateless = "false"
  }
  ingress_security_rules {
    description = "TCP access from Kubernetes Control Plane"
    protocol    = "6"
    source      = "10.0.0.0/28"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Inbound SSH traffic to worker nodes"
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = "false"
  }
  vcn_id = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_core_security_list" "kubernetes_api_endpoint_sec_list" {
  compartment_id = var.compartment_ocid
  display_name   = "oke-k8sApiEndpoint-quick-cluster1-a081805fa"
  egress_security_rules {
    description      = "Allow Kubernetes Control Plane to communicate with OKE"
    destination      = "all-iad-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "All traffic to worker nodes"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }
  egress_security_rules {
    description      = "Path discovery"
    destination      = "10.0.10.0/24"
    destination_type = "CIDR_BLOCK"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    stateless = "false"
  }
  ingress_security_rules {
    description = "External access to Kubernetes API endpoint"
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    protocol    = "6"
    source      = "10.0.10.0/24"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Kubernetes worker to control plane communication"
    protocol    = "6"
    source      = "10.0.10.0/24"
    stateless   = "false"
  }
  ingress_security_rules {
    description = "Path discovery"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol  = "1"
    source    = "10.0.10.0/24"
    stateless = "false"
  }
  vcn_id = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_containerengine_cluster" "generated_oci_containerengine_cluster" {
  cluster_pod_network_options {
    cni_type = "OCI_VCN_IP_NATIVE"
  }
  compartment_id = var.compartment_ocid
  endpoint_config {
    is_public_ip_enabled = "true"
    subnet_id            = oci_core_subnet.kubernetes_api_endpoint_subnet.id
  }
  freeform_tags = {
    "OKEclusterName" = "cluster1"
  }
  kubernetes_version = "v1.36"
  name               = "cluster1"
  options {
    admission_controller_options {
      is_pod_security_policy_enabled = "false"
    }
    persistent_volume_config {
      freeform_tags = {
        "OKEclusterName" = "cluster1"
      }
    }
    service_lb_config {
      freeform_tags = {
        "OKEclusterName" = "cluster1"
      }
    }
    service_lb_subnet_ids = ["${oci_core_subnet.service_lb_subnet.id}"]
  }
  type   = "ENHANCED_CLUSTER"
  vcn_id = oci_core_vcn.generated_oci_core_vcn.id
}

resource "oci_containerengine_node_pool" "create_node_pool_details0" {
  cluster_id     = oci_containerengine_cluster.generated_oci_containerengine_cluster.id
  compartment_id = var.compartment_ocid
  freeform_tags = {
    "OKEnodePoolName" = "pool1"
  }
  initial_node_labels {
    key   = "name"
    value = "cluster1"
  }
  kubernetes_version = "v1.36"
  name               = "pool1"
  node_config_details {
    freeform_tags = {
      "OKEnodePoolName" = "pool1"
    }
    is_pv_encryption_in_transit_enabled = "false"
    node_pool_pod_network_option_details {
      cni_type          = "OCI_VCN_IP_NATIVE"
      max_pods_per_node = "31"
      pod_subnet_ids    = ["${oci_core_subnet.node_subnet.id}"]
    }
    placement_configs {
      availability_domain = "chRR:US-ASHBURN-AD-1"
      subnet_id           = oci_core_subnet.node_subnet.id
    }
    placement_configs {
      availability_domain = "chRR:US-ASHBURN-AD-2"
      subnet_id           = oci_core_subnet.node_subnet.id
    }
    placement_configs {
      availability_domain = "chRR:US-ASHBURN-AD-3"
      subnet_id           = oci_core_subnet.node_subnet.id
    }
    size = "3"
  }
  node_eviction_node_pool_settings {
    eviction_grace_duration              = "PT60M"
    is_force_delete_after_grace_duration = "false"
  }
  node_shape = "VM.Standard.E3.Flex"
  node_shape_config {
    memory_in_gbs = "16"
    ocpus         = "1"
  }
  node_source_details {
    boot_volume_size_in_gbs = "50"
    image_id                = "ocid1.image.oc1.iad.aaaaaaaa3bdqvy6qlveex2426k36otoo575a7ojsitkzl553uj6xpojwtttq"
    source_type             = "IMAGE"
  }
}

data "oci_containerengine_cluster_kube_config" "oke_kubeconfig" {
  cluster_id = oci_containerengine_cluster.generated_oci_containerengine_cluster.id
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "6.7.11"
  namespace        = "argocd"
  create_namespace = true

  depends_on = [
    oci_containerengine_node_pool.create_node_pool_details0
  ]

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}

data "kubernetes_service" "argocd_server_status" {
  metadata {
    name      = "argocd-server"
    namespace = helm_release.argocd.namespace
  }

  depends_on = [helm_release.argocd]
}

resource "kubernetes_manifest" "api_argocd" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "cicd-oci"
      namespace = helm_release.argocd.namespace
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/ShlomoChanoch/cicd-oci.git" # Substituta pelo seu repo público
        targetRevision = "main"                                          # Branch (ex: main, HEAD, etc)
        path           = "k8s"                                           # Pasta no Git onde estão os YAMLs da app
      }
      destination = {
        server    = "https://kubernetes.default.svc" # O próprio cluster OKE local
        namespace = "default"                        # Namespace onde a app vai rodar
      }
      syncPolicy = {
        automated = {
          prune    = true # Deleta do K8s se você deletar do Git
          selfHeal = true # Recria se alguém alterar manualmente no cluster
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  }

  depends_on = [
    helm_release.argocd
  ]
}