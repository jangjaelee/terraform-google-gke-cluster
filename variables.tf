variable "project_id" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "region" {
    description = "The default region to manage resources in."
    type        = string
}

variable "labels" {
  description = "labels"
  type        = map(string)
}


####################
# Cluster basics
####################
variable "cluster_name" {
  description = "The name of the cluster, unique within the project and location."
  type        = string
}

variable "cluster_description" {
  description = "Description of the cluster."
  type        = string
}

variable "cluster_location_type" {
  description = "The location (region or zone) in which the cluster master will be created. If you specify a zone (such as us-central1-a), the cluster will be a zonal cluster with a single cluster master. If you specify a region (such as us-west1), the cluster will be a regional cluster with multiple masters spread across zones in the region."
  type        = string
}

variable "node_locations" {
  description = "value"
  type        = list
}

variable "release_channel" {
  description = "The release channel of this cluster. Accepted values are `UNSPECIFIED`, `RAPID`, `REGULAR` and `STABLE`. Defaults to `UNSPECIFIED`."
  type        = string
}

variable "kubernetes_version" {
  description = "The Kubernetes version of the masters."
  type        = string
}


####################
# Networking
####################
variable "vpc_network" {
  description = "The name or self_link of the Google Compute Engine network to which the cluster is connected. For Shared VPC, set this to the self link of the shared network."
  type        = string
}

variable "subnetwork" {
  description = "The name or self_link of the Google Compute Engine subnetwork in which the cluster's instances are launched."
  type        = string
}

variable "enable_private_endpoint" {
  description = "When true, the cluster's private endpoint is used as the cluster endpoint and access through the public endpoint is disabled. When false, either endpoint can be used."
  type        = bool
}

variable "enable_private_nodes" {
  description = "Enables the private cluster feature, creating a private endpoint on the cluster. In a private cluster, nodes only have RFC 1918 private addresses and communicate with the master's private endpoint via private networking."
  type        = bool
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation to use for the hosted master network. This range will be used for assigning private IP addresses to the cluster master(s) and the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network, and it must be a /28 subnet."
  type        = string
}

variable "master_global_access_config" {
  description = "Whether the cluster master is accessible globally or not."
  type        = bool
}

variable "networking_mode" {
  description = "Determines whether alias IPs or routes will be used for pod IPs in the cluster. Options are VPC_NATIVE or ROUTES."
  type        = string
}

variable "cluster_ipv4_cidr_block" {
  description = "The name of the existing secondary range in the cluster's subnetwork to use for pod IP addresses."
  type        = string
}

variable "services_ipv4_cidr_block" {
  description = "The IP address range for the cluster pod IPs. Set to blank to have a range chosen with the default size. Set to /netmask (e.g. /14) to have a range chosen with a specific netmask. Set to a CIDR notation (e.g. 10.96.0.0/14) from the RFC-1918 private networks (e.g. 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to pick a specific range to use."
  type        = string
}

variable "max_pods_per_node" {
  description = "The maximum number of pods to schedule per node."
  type        = number
}

variable "gke_cni" {
  description = "The desired GKE CNI for this cluster. By default, `cilium` enables the Dataplane v2 feature. `calico` enables the Network Policy feature. `kube-proxy` enables the IPTables-based kube-proxy implementation"
  type        = string
}

variable "network_policy" {
  description = "The Node Pool use calico CNI."
  type        = bool
}

variable "enable_intranode_visibility" {
  description = "Whether Intra-node visibility is enabled for this cluster. This makes same node pod to pod traffic visible for VPC network."
  type        = bool
}

variable "enable_l4_ilb_subsetting" {
  description = "Enable L4 ILB Subsetting on the cluster."
  type        = bool
}

variable "cluster_dns_provider" {
  type        = string
  description = "Which in-cluster DNS provider should be used. PROVIDER_UNSPECIFIED (default) or PLATFORM_DEFAULT or CLOUD_DNS."
  default     = "PROVIDER_UNSPECIFIED"
}

variable "cluster_dns_scope" {
  type        = string
  description = "The scope of access to cluster DNS records. DNS_SCOPE_UNSPECIFIED (default) or CLUSTER_SCOPE or VPC_SCOPE. "
  default     = "DNS_SCOPE_UNSPECIFIED"
}

variable "cluster_dns_domain" {
  type        = string
  description = "The suffix used for all cluster service records."
  default     = ""
}

variable "master_authorized_networks" {
  description = "List of master authorized networks. If none are provided, disallow external access (except the cluster node IPs, which GKE automatically whitelists)."
  type        = list(object({ cidr_block = string, display_name = string }))
}

variable "service_external_ips" {
  description = "Whether external ips specified by a service will be allowed in this cluster"
  type        = bool
}


####################
# Automation
####################
variable "maintenance_policy" {
  description = "The maintenance policy to use for the cluster. `enabled` or `disabled`."
  type        = string
}

variable "maintenance_start_time" {
  description = "Time window specified for daily or recurring maintenance operations in RFC3339 format"  
  type        = string
}

variable "maintenance_end_time" {
  description = "Time window specified for recurring maintenance operations in RFC3339 format"
  type        = string
}

variable "maintenance_exclusions" {
  description = "List of maintenance exclusions. A cluster can have up to three"
  type        = list(object({ name = string, start_time = string, end_time = string, exclusion_scope = string }))
}

variable "maintenance_recurrence" {
  description = "Frequency of the recurring maintenance window in RFC5545 format."
  type        = string
}

variable "vertical_pod_autoscaling" {
  description = "Vertical Pod Autoscaling automatically adjusts the resources of pods controlled by it"
  type        = bool
}

variable "cluster_autoscaling" {
  description = "Cluster autoscaling configuration. See [more details](https://cloud.google.com/kubernetes-engine/docs/reference/rest/v1beta1/projects.locations.clusters#clusterautoscaling)"  
  type = object({
    enabled             = bool
    autoscaling_profile = string  # PROFILE_UNSPECIFIED, OPTIMIZE_UTILIZATION, BALANCED
    min_cpu_cores       = number
    max_cpu_cores       = number
    min_memory_gb       = number
    max_memory_gb       = number
    gpu_resources       = list(object({ resource_type = string, minimum = number, maximum = number }))
  })
}


####################
# addons_config
####################
variable "http_load_balancing" {
  description = "The status of the HTTP (L7) load balancing controller addon, which makes it easy to set up HTTP load balancers for services in a cluster."
  type        = bool
}

variable "dns_cache_config" {
  description = "The status of the NodeLocal DNSCache addon. It is disabled by default. Set enabled = true to enable."
  type        = bool
}

variable "horizontal_pod_autoscaling" {
  description = "The status of the Horizontal Pod Autoscaling addon, which increases or decreases the number of replica pods a replication controller has based on the resource usage of the existing pods."
  type        = bool
}


####################
# Security
####################
variable "binary_authorization" {
  description = "Configuration options for the Binary Authorization feature. If unspecified, defaults to DISABLED."
  type        = string
}

variable "enable_shielded_nodes" {
  description = "Enable Shielded Nodes features on all nodes in this cluster."
  type        = bool
}

variable "enable_confidential_nodes" {
  description = "An optional flag to enable confidential node config."
  type        = bool
}

variable "database_encryption" {
  description = "Application-layer Secrets Encryption settings. The object format is {state = string, key_name = string}. Valid values of state are: \"ENCRYPTED\"; \"DECRYPTED\". key_name is the name of a CloudKMS key."
  type        = list(object({ state = string, key_name = string }))
}

variable "identity_namespace" {
  description = "The workload pool to attach all Kubernetes service accounts to. (Default value of `enabled` automatically sets project-based pool `[project_id].svc.id.goog`)"
  type        = string
}

variable "authenticator_security_group" {
  description = "The name of the RBAC security group for use with Google security groups in Kubernetes RBAC. Group name must be in format gke-security-groups@yourdomain.com"
  type        = string
}


####################
# Metadata
####################
variable "cluster_resource_labels" {
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster"
  type        = map(string)
}


####################
# Features
####################