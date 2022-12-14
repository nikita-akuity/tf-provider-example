variable "project_id" {
  description = "The GCP project to use for integration tests"
  type        = string
}

variable "region" {
  description = "The GCP region to create and test resources in"
  type        = string
}

variable "zones" {
  description = "The GCP zones to create resources in"
  type        = map(string)
}

variable "cidr_base" {
    description = "Base cidr for creatinf subnets"
    type        = string
}
