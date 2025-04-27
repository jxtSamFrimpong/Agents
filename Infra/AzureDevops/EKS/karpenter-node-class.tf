# resource "kubectl_manifest" "karpenter_node_class" {
#   yaml_body = local.node_class_config

#   depends_on = [
#     helm_release.karpenter
#   ]
# }

resource "helm_release" "karpenter_node_class" {
  depends_on = [helm_release.karpenter]
  name       = "exeter-dev-node-class"
  repository = "https://bedag.github.io/helm-charts"
  chart      = "raw"
  version    = "2.0.0"
  values = [
    yamlencode({
        resources = [local.node_class_config]
    })
  ]

  lifecycle {
    create_before_destroy = true
  }
}