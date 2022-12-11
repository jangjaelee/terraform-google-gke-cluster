data "google_container_engine_versions" "this" {
  project        = var.project_id
  location       = var.cluster_location_type
  version_prefix = var.kubernetes_version
}

resource "google_container_cluster" "gke_cluster_standard" {
####################
# Cluster basics
####################
  name                 = var.cluster_name
  description          = var.cluster_description
  location             = var.cluster_location_type
  node_locations       = var.node_locations
  
  release_channel {
    channel = var.release_channel
  }

  #min_master_version = data.google_container_engine_versions.this.default_cluster_version
  min_master_version = "1.24.5-gke.600"


####################
# Networking
####################
  network          = "projects/${var.project_id}/global/networks/${var.vpc_network}"
  subnetwork       = var.subnetwork

  private_cluster_config {
    enable_private_endpoint = var.enable_private_endpoint
    enable_private_nodes    = var.enable_private_nodes  
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block

    master_global_access_config {
      enabled = var.master_global_access_config
    }
  }

  #default_snat_status {
  #  disabled = 
  #} 

  networking_mode  = var.networking_mode   # VPC_NATIVE or ROUTES

  ip_allocation_policy {
    cluster_ipv4_cidr_block       = var.cluster_ipv4_cidr_block
    services_ipv4_cidr_block      = var.services_ipv4_cidr_block
  }

  network_policy {
    enabled  = false
    provider = "PROVIDER_UNSPECIFIED"
  }

  datapath_provider = var.datapath_provider ? "ADVANCED_DATAPATH" : "DATAPATH_PROVIDER_UNSPECIFIED"

  master_authorized_networks_config {
    cidr_blocks {
      #cidr_block   = lookup(cidr_blocks.value, "cidr_block", "")
      #display_name = lookup(cidr_blocks.value, "display_name", "")
      cidr_block   = var.master_authorized_networks_cidr_block
      display_name = var.master_authorized_networks_display_name

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
}