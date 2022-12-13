locals {
  module_name    = "terraform-google-gke-cluster-standard"
  module_version = "v0.0.1"

  # The desired configuration options for master authorized networks
  master_authorized_networks_config = length(var.master_authorized_networks) == 0 ? [] : [{
    cidr_blocks : var.master_authorized_networks
  }]

  # `kube-proxy` enables the IPTables-based kube-proxy implementation feature.
  gke_cni_kubenet = var.gke_cni == "kube-proxy" ? true : false

  # `calico` enables the Network Policy feature.
  gke_cni_calico  = var.gke_cni == "calico" ? true : false

  # `cilium` enables the Dataplane v2 feature.
  gke_cni_cilium  = var.gke_cni == "cilium" ? true : false

  # The maintenance policy to use for the cluster
  cluster_maintenance_window_is_recurring = var.maintenance_recurrence != "" && var.maintenance_end_time != "" ? [1] : []
  cluster_maintenance_window_is_daily     = length(local.cluster_maintenance_window_is_recurring) > 0 ? [] : [1]

}