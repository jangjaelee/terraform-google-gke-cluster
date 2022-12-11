variable "project_id" {
    description = "The ID of the project in which the resource belongs."
    type        = string
}

variable "region" {
    description = "The default region to manage resources in."
    type        = string
}

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

variable "vpc_network" {
    description = "The name or self_link of the Google Compute Engine network to which the cluster is connected. For Shared VPC, set this to the self link of the shared network."
    type        = string
}

variable "subnetwork" {
    description = "The name or self_link of the Google Compute Engine subnetwork in which the cluster's instances are launched."
    type        = string
}

variable "cluster_ipv4_cidr_block" {
    description = "The name of the existing secondary range in the cluster's subnetwork to use for pod IP addresses."
    type        = string
}

# variable "cluster_secondary_range_name" {
#     description = "The IP address range of the Kubernetes pods in this cluster in CIDR notation (e.g. 10.96.0.0/14). Leave blank to have one automatically chosen or specify a /14 block in 10.0.0.0/8."
#     type        = string
# }

variable "services_ipv4_cidr_block" {
    description = "The IP address range for the cluster pod IPs. Set to blank to have a range chosen with the default size. Set to /netmask (e.g. /14) to have a range chosen with a specific netmask. Set to a CIDR notation (e.g. 10.96.0.0/14) from the RFC-1918 private networks (e.g. 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to pick a specific range to use."
    type        = string
}

# variable "services_secondary_range_name" {
#     description = " The name of the existing secondary range in the cluster's subnetwork to use for service ClusterIPs. Alternatively, services_ipv4_cidr_block can be used to automatically create a GKE-managed one."
#     type        = string
# }

variable "datapath_provider" {
  description = "The desired datapath provider for this cluster. By default, `DATAPATH_PROVIDER_UNSPECIFIED` enables the IPTables-based kube-proxy implementation. `ADVANCED_DATAPATH` enables Dataplane-V2 feature."
  type        = bool
}