variable "google_project_id" {
  description = "The GCP project to use for integration tests"
  type        = string
}

variable "google_region" {
  description = "The GCP region to create and test resources in"
  type        = string
}

variable "google_zones" {
  description = "The GCP zones to create resources in"
  type        = list(string)
}

variable "google_cidr_base" {
    description = "Base cidr for creating subnets"
    type        = string
}

variable "aws_region" {
  description = "The AWS region to create and test resources in"
  type        = string
}

variable "aws_zones" {
  description = "The AWS zones to create resources in"
  type        = list(string)
}

variable "aws_cidr_base" {
    description = "Base cidr for creating subnets"
    type        = string
}

variable "akuity_org_name" {
    description = "Organization name in Akuity Platform"
    type        = string
}
