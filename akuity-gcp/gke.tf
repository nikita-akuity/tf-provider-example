provider "google" {
  project     = var.google_project_id
  region      = var.google_region
}

module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 6.0"
  project_id   = var.google_project_id
  network_name = "example-vpc"

  subnets = [
    {
      subnet_name   = "example-subnet"
      subnet_ip     = cidrsubnet(var.google_cidr_base, 4, 1)
      subnet_region = var.google_region
    }
  ]
  secondary_ranges = {
    example-subnet = [
      {
        range_name = "example-gke-pods"
        ip_cidr_range = "192.168.64.0/20"
      },
      {
        range_name = "example-gke-services"
        ip_cidr_range = "192.168.80.0/24"
      }
    ]
  }
}

resource "google_compute_router" "router" {
  project = var.google_project_id
  name    = "router-${var.google_region}"
  network = module.vpc.network_self_link
  region  = var.google_region
}

module "cloud-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 2.0"
  project_id                         = var.google_project_id
  region                             = var.google_region
  router                             = google_compute_router.router.name
  name                               = "nat-${var.google_region}"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version                    = "24.1.0"
  project_id                 = var.google_project_id
  name                       = "gke-example-1"
  region                     = var.google_region
  zones                      = var.google_zones
  network                    = module.vpc.network_name
  subnetwork                 = module.vpc.subnets_names[0]
  ip_range_pods              = "example-gke-pods"
  ip_range_services          = "example-gke-services"
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  enable_private_endpoint    = false
  enable_private_nodes       = true
  node_pools = [{
    name                     = "spot-cpu-pool"
    machine_type             = "e2-highcpu-4"
    node_locations           = join(",",var.google_zones)
    min_count                = 1
    max_count                = 3
    local_ssd_count          = 0
    spot                     = true
    disk_size_gb             = 100
    disk_type                = "pd-standard"
    image_type               = "COS_CONTAINERD"
    preemptible              = false
    initial_node_count       = 1
    location_policy          = "ANY"
  }]
  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
  node_pools_labels = {
    all = {}
    spot-cpu-pool = {
      spot = true
      highcpu = true
    }
  }
}
