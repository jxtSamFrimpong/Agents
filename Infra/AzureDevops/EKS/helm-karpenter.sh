#!/bin/bash
#https://artifacthub.io/packages/helm/aws-karpenter/karpenter
#https://karpenter.sh/docs/getting-started/getting-started-with-karpenter/
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter --version "${KARPENTER_VERSION}" --namespace "${KARPENTER_NAMESPACE}" --create-namespace   --set "settings.clusterName=${CLUSTER_NAME}"         --set serviceAccount.name="karpenter"