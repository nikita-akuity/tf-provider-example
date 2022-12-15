provider akp {
  org_name = var.akuity_org_name
}

resource "akp_instance" "argocd" {
  name    = "tf-managed-example"
  version = "v2.5.3"
}
