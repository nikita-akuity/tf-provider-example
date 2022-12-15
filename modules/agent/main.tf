data "kubectl_file_documents" "agent" {
    content = var.manifests
}

resource "kubectl_manifest" "agent_namespace" {
    yaml_body = lookup(data.kubectl_file_documents.agent.manifests, "/api/v1/namespaces/${var.namespace}/namespaces/${var.namespace}")
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
