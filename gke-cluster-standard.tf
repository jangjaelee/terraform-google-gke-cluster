# data "google_container_engine_versions" "this" {
#   project        = var.project_id
#   location       = var.cluster_location_type
#   version_prefix = var.kubernetes_version
# }


resource "google_container_cluster" "gke_cluster_standard" {
####################
# Cluster basics
####################s
  project              = var.project_id
  name                 = var.cluster_name
  description          = var.cluster_description
  location             = var.cluster_location_type
  node_locations       = var.node_locations

  #min_master_version   = data.google_container_engine_versions.this.default_cluster_version
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
    enabled  = local.gke_cni_calico ? true : false
    provider = local.gke_cni_calico ? "CALICO" : "PROVIDER_UNSPECIFIED"
  }

  datapath_provider = local.gke_cni_cilium ? "ADVANCED_DATAPATH" : "DATAPATH_PROVIDER_UNSPECIFIED"

  enable_intranode_visibility = var.enable_intranode_visibility

  enable_l4_ilb_subsetting = var.enable_l4_ilb_subsetting

  dynamic "dns_config" {
    for_each = var.cluster_dns_provider == "CLOUD_DNS" ? [1] : []
    content {
      cluster_dns        = var.cluster_dns_provider
      cluster_dns_scope  = var.cluster_dns_scope
      cluster_dns_domain = var.cluster_dns_domain
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


####################
# addons_config
####################
  addons_config {
    network_policy_config {
      disabled = !var.network_policy
    }

    http_load_balancing {
      disabled = !var.http_load_balancing
    }

    dns_cache_config {
      enabled = var.dns_cache_config
    }

    horizontal_pod_autoscaling {
      disabled = !var.horizontal_pod_autoscaling
    }
  }


####################
# Automation
####################
  dynamic maintenance_policy {
    for_each = var.maintenance_policy == "enabled" ? [1] : []
    content {
      dynamic "recurring_window" {
        for_each = local.cluster_maintenance_window_is_recurring
        content {
          start_time = var.maintenance_start_time
          end_time   = var.maintenance_end_time
          recurrence = var.maintenance_recurrence
        }
      }

      dynamic "daily_maintenance_window" {
        for_each = local.cluster_maintenance_window_is_daily
        content {
          start_time = var.maintenance_start_time
        }
      }

      dynamic "maintenance_exclusion" {
        for_each = var.maintenance_exclusions
        content {
          exclusion_name = maintenance_exclusion.value.name
          start_time     = maintenance_exclusion.value.start_time
          end_time       = maintenance_exclusion.value.end_time

          dynamic "exclusion_options" {
            for_each = maintenance_exclusion.value.exclusion_scope == null ? [] : [maintenance_exclusion.value.exclusion_scope]
            content {
              scope = exclusion_options.value
            }
          }
        }
      }
    }
  }

  #--> this can use in google-beta provider
  # node_pool_auto_config {
  #   network_tags {
  #     tags = ["ssh-bastion"]
  #   }
  # }

  vertical_pod_autoscaling {
    enabled = var.vertical_pod_autoscaling
  }

  cluster_autoscaling {
    enabled = var.cluster_autoscaling.enabled

    # dynamic "auto_provisioning_defaults" {
    #   for_each = var.cluster_autoscaling.enabled ? [1] : []

    #   content {
    #     service_account  = local.service_account
    #     oauth_scopes     = local.node_pools_oauth_scopes["all"]
    #     min_cpu_platform = lookup(var.node_pools[0], "min_cpu_platform", "")
    #   }
    # }

    #--> this can use in google-beta provider
    #autoscaling_profile = var.cluster_autoscaling.autoscaling_profile != null ? var.cluster_autoscaling.autoscaling_profile : "BALANCED"

    dynamic "resource_limits" {
      for_each = local.autoscaling_resource_limits
      content {
        resource_type = lookup(resource_limits.value, "resource_type")
        minimum       = lookup(resource_limits.value, "minimum")
        maximum       = lookup(resource_limits.value, "maximum")
      }
    }
  }


####################
# Security
####################
  binary_authorization {
    evaluation_mode = var.binary_authorization
  }


####################
# Metadata
####################


####################
# Features
####################




  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  # lifecycle {
  #   ignore_changes = [node_pool, initial_node_count, resource_labels["asmv"], resource_labels["mesh_id"]]
  # }

  # timeouts {
  #   create = lookup(var.timeouts, "create", "60m")
  #   update = lookup(var.timeouts, "update", "60m")
  #   delete = lookup(var.timeouts, "delete", "60m")
  # }
}