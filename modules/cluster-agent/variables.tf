variable instance_id {
  type        = string
  description = "Argo CD Instance ID"
}
variable name {
  type        = string
  description = "Cluster name"
}
variable namespace {
  type        = string
  default     = "akuity"
  description = "Agent installation namespace"
}
variable namespace_scoped {
  type        = bool
  default     = false
  description = "Generate namespace-scoped manifests"
}
variable size {
  type        = string
  default     = "small"
  description = "Cluster size"
}
variable labels {
  type        = map(string)
  description = "Cluster labels"
}
variable annotations {
  type        = map(string)
  default     = {}
  description = "Cluster annotations"
}
