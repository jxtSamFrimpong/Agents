# resource "kubectl_manifest" "karpenter_node_pool" {
#   yaml_body = local.node_pool_config

#   depends_on = [
#     kubectl_manifest.karpenter_node_class,
#     helm_release.karpenter
#   ]
# }

resource "helm_release" "karpenter_node_pool" {
  depends_on = [helm_release.karpenter, helm_release.karpenter_node_class]
  name       = "exeter-dev-karpenter-pool"
  repository = "https://bedag.github.io/helm-charts"
  chart      = "raw"
  version    = "2.0.0"
  values = [
    yamlencode({
        resources = [local.node_pool_config]
    })
  ]
}