locals {
    manifest_count = 31
}

resource "akp_cluster" "cluster" {
  instance_id      = var.instance_id
  name             = var.name
  namespace        = var.namespace
  namespace_scoped = var.namespace_scoped
  size             = var.size
  labels           = var.labels
  annotations      = var.annotations
}

data "kubectl_file_documents" "agent" {
  content = akp_cluster.cluster.manifests
}

resource "kubectl_manifest" "agent_namespace" {
  yaml_body = element(data.kubectl_file_documents.agent.documents, 0)
  wait      = true
  lifecycle {
    ignore_changes = [
      yaml_body
    ]
  }
}

resource "kubectl_manifest" "agent" {
  count     = local.manifest_count - 1
  yaml_body = element(data.kubectl_file_documents.agent.documents, count.index + 1)
  # Important!
  wait_for_rollout = false
  depends_on = [
      kubectl_manifest.agent_namespace
  ]
  # Agent manages itself, no need to reapply manifests
  lifecycle {
    ignore_changes = [
      yaml_body
    ]
  }
}
