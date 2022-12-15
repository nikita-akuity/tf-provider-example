variable manifests {
  type        = string
  description = "Agent Manifests to apply"
}

variable namespace {
  type        = string
  default     = "akuity"
  description = "Namespace to install agent to"
}

