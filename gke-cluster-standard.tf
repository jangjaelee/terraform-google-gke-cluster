# data "google_container_engine_versions" "this" {
#   project        = var.project_id
#   location       = var.cluster_location_type
#   version_prefix = var.kubernetes_version
# }

resource "google_container_cluster" "gke_cluster_standard" {
####################
# Cluster basics
####################
  name                 = var.cluster_name
  description          = var.cluster_description
  location             = var.cluster_location_type
  node_locations       = var.node_locations

  #min_master_version   = data.google_container_engine_versions.this.default_cluster_version
  #min_master_version   = "1.24.5-gke.600"
  min_master_version   = var.kubernetes_version  
  release_channel {
    channel = var.release_channel
  }


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

  default_max_pods_per_node = var.max_pods_per_node

  network_policy {
    # enabled  = var.network_policy ? true : false
    # provider = var.network_policy ? "CALICO" : "PROVIDER_UNSPECIFIED"
    enabled  = local.gke_cni_calico ? true : false
    provider = local.gke_cni_calico ? "CALICO" : "PROVIDER_UNSPECIFIED"
  }

  datapath_provider = local.gke_cni_cilium ? "ADVANCED_DATAPATH" : "DATAPATH_PROVIDER_UNSPECIFIED"

  addons_config {
    network_policy_config {
      disabled = !var.network_policy
    }

    http_load_balancing {
      disabled = !var.http_load_balancing
    }


  }

  dynamic "master_authorized_networks_config" {
    for_each = local.master_authorized_networks_config
    content {
      dynamic "cidr_blocks" {
        for_each = master_authorized_networks_config.value.cidr_blocks
        content {
          cidr_block   = lookup(cidr_blocks.value, "cidr_block", "")
          display_name = lookup(cidr_blocks.value, "display_name", "")
        }
      }
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

  # lifecycle {
  #   ignore_changes = [node_pool, initial_node_count, resource_labels["asmv"], resource_labels["mesh_id"]]
  # }

  timeouts {
    create = lookup(var.timeouts, "create", "60m")
    update = lookup(var.timeouts, "update", "60m")
    delete = lookup(var.timeouts, "delete", "60m")
  }
}