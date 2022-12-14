provider akp {
  org_name = var.akuity_org_name
}

resource "akp_instance" "example" {
  name    = "example-argocd-instance"
  version = "v2.5.3"
}
