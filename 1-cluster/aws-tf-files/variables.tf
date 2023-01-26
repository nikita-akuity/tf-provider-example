variable "aws_region" {
  description = "The AWS region to create and test resources in"
  type        = string
}

variable "aws_cidr_base" {
    description = "Base cidr for creating subnets"
    type        = string
}

variable "azure_region" {
  description = "The Azure region to create and test resources in"
  type        = string
}

variable "akuity_org_name" {
    description = "Organization name in Akuity Platform"
    type        = string
}
