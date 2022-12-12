locals {
  master_authorized_networks_config = length(var.master_authorized_networks) == 0 ? [] : [{
    cidr_blocks : var.master_authorized_networks
  }]

  # `kube-proxy` enables the IPTables-based kube-proxy implementation feature.
  gke_cni_kubenet = var.gke_cni == "kube-proxy" ? true : false

  # `calico` enables the Network Policy feature.
  gke_cni_calico  = var.gke_cni == "calico" ? true : false

  # `cilium` enables the Dataplane v2 feature.
  gke_cni_cilium  = var.gke_cni == "cilium" ? true : false  
}