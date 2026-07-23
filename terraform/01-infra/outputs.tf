output "cluster_id" {
  value       = oci_containerengine_cluster.generated_oci_containerengine_cluster.id
  description = "OCID do cluster OKE criado"
}