variable "azure_region" {
  description = "The Azure region to create and test resources in"
  type        = string
}

variable "azure_cidr_base" {
    description = "Base cidr for creating subnets"
    type        = string
}

variable "akuity_org_name" {
    description = "Organization name in Akuity Platform"
    type        = string
}

variable "prefix" {
  description = "Prefix for reaource names"
  type        = string
}
