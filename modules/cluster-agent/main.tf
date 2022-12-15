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
}

resource "kubectl_manifest" "agent" {
    count     = 31
    yaml_body = element(data.kubectl_file_documents.agent.documents, count.index)
    # Important!
    wait_for_rollout = false
    depends_on = [
        kubectl_manifest.agent_namespace
    ]
}
