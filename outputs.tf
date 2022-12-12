# output "stable_channel_version" {
#   #value = data.google_container_engine_versions.this.release_channel_default_version["STABLE"]
#   #value = data.google_container_engine_versions.this.valid_master_versions
#   value = data.google_container_engine_versions.this.default_cluster_version
# }

output "datapath_provider" {
  value = google_container_cluster.gke_cluster_standard.datapath_provider
}

output "gke_cni_kubenet" {
  value = local.gke_cni_kubenet
}

output "gke_cni_calico" {
  value = local.gke_cni_calico
}

output "gke_cni_cilium" {
  value = local.gke_cni_cilium
}