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

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.google_project_id
  name                       = "gke-test-1"
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
}
