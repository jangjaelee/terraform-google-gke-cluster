data "google_container_engine_versions" "this" {
  project        = var.project_id
  location       = var.cluster_location_type
  version_prefix = "1.24."
}

resource "google_container_cluster" "gke_cluster_standard" {
  name                     = var.cluster_name
  location                 = var.cluster_location_type
  node_locations           = var.node_locations
  network                  = "projects/${var.project_id}/global/networks/${var.vpc_network}"
  subnetwork               = var.subnetwork
  
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }

  network_policy {
    enabled  = false
    provider = "PROVIDER_UNSPECIFIED"
  }

  networking_mode = "VPC_NATIVE"
  datapath_provider = var.datapath_provider ? "ADVANCED_DATAPATH" : "DATAPATH_PROVIDER_UNSPECIFIED"

  enable_tpu       = false

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = false

    master_global_access_config {
        enabled = false
    }
}


  binary_authorization {
    evaluation_mode = "DISABLED"
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = "UNSPECIFIED"
  }

  #min_master_version = data.google_container_engine_versions.this.default_cluster_version
  min_master_version = "1.24.5-gke.600"
}
