apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: "${karpenterNodePoolName}"
spec:
  # Template section that describes how to template out NodeClaim resources that Karpenter will provision
  # Karpenter will consider this template to be the minimum requirements needed to provision a Node using this NodePool
  # It will overlay this NodePool with Pods that need to schedule to further constrain the NodeClaims
  # Karpenter will provision to launch new Nodes for the cluster
  template:
    metadata:
      # Labels are arbitrary key-values that are applied to all nodes
      labels:
        billing-team: my-team

      # Annotations are arbitrary key-values that are applied to all nodes
      annotations:
        example.com/owner: "exeter"
    spec:
      # References the Cloud Provider's NodeClass resource, see your cloud provider specific documentation
      nodeClassRef:
        group: karpenter.k8s.aws  # Updated since only a single version will be served
        kind: EC2NodeClass
        name: "${karpenterNodeClassName}"

      ## Provisioned nodes will have these taints
      ## Taints may prevent pods from scheduling if they are not tolerated by the pod.
      #taints:
      #  - key: example.com/special-taint
      #    effect: NoSchedule

      ## Provisioned nodes will have these taints, but pods do not need to tolerate these taints to be provisioned by this
      ## NodePool. These taints are expected to be temporary and some other entity (e.g. a DaemonSet) is responsible for
      ## removing the taint after it has finished initializing the node.
      #startupTaints:
      #  - key: example.com/another-taint
      #    effect: NoSchedule

      # The amount of time a Node can live on the cluster before being removed
      # Avoiding long-running Nodes helps to reduce security vulnerabilities as well as to reduce the chance of issues that can plague Nodes with long uptimes such as file fragmentation or memory leaks from system processes
      # You can choose to disable expiration entirely by setting the string value 'Never' here

      # Note: changing this value in the nodepool will drift the nodeclaims.
      expireAfter: 720h #| Never

      # The amount of time that a node can be draining before it's forcibly deleted. A node begins draining when a delete call is made against it, starting
      # its finalization flow. Pods with TerminationGracePeriodSeconds will be deleted preemptively before this terminationGracePeriod ends to give as much time to cleanup as possible.
      # If your pod's terminationGracePeriodSeconds is larger than this terminationGracePeriod, Karpenter may forcibly delete the pod
      # before it has its full terminationGracePeriod to cleanup.

      # Note: changing this value in the nodepool will drift the nodeclaims.
      terminationGracePeriod: 48h

      # Requirements that constrain the parameters of provisioned nodes.
      # These requirements are combined with pod.spec.topologySpreadConstraints, pod.spec.affinity.nodeAffinity, pod.spec.affinity.podAffinity, and pod.spec.nodeSelector rules.
      # Operators { In, NotIn, Exists, DoesNotExist, Gt, and Lt } are supported.
      # https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#operators
      requirements:
        - key: node.kubernetes.io/instance-type
          operator: In
          values: ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
        - key: "kubernetes.io/arch"
          operator: In
          values: ["amd64"]
        - key: "karpenter.sh/capacity-type"
          operator: In
          values: ["spot"]

  # Disruption section which describes the ways in which Karpenter can disrupt and replace Nodes
  # Configuration in this section constrains how aggressive Karpenter can be with performing operations
  # like rolling Nodes due to them hitting their maximum lifetime (expiry) or scaling down nodes to reduce cluster cost
  disruption:
    # Describes which types of Nodes Karpenter should consider for consolidation
    # If using 'WhenEmptyOrUnderutilized', Karpenter will consider all nodes for consolidation and attempt to remove or replace Nodes when it discovers that the Node is empty or underutilized and could be changed to reduce cost
    # If using `WhenEmpty`, Karpenter will only consider nodes for consolidation that contain no workload pods
    consolidationPolicy: WhenEmptyOrUnderutilized #| WhenEmpty

    # The amount of time Karpenter should wait to consolidate a node after a pod has been added or removed from the node.
    # You can choose to disable consolidation entirely by setting the string value 'Never' here
    consolidateAfter: 1m #| Never # Added to allow additional control over consolidation aggressiveness

    # Budgets control the speed Karpenter can scale down nodes.
    # Karpenter will respect the minimum of the currently active budgets, and will round up
    # when considering percentages. Duration and Schedule must be set together.
    budgets:
    - nodes: 10%
    ## On Weekdays during business hours, don't do any deprovisioning.
    #- schedule: "0 9 * * mon-fri"
    #  duration: 8h
    #  nodes: "0"

  # Resource limits constrain the total size of the pool.
  # Limits prevent Karpenter from creating new instances once the limit is exceeded.
  limits:
    cpu: "1000"
    memory: 1000Gi

  # Priority given to the NodePool when the scheduler considers which NodePool
  # to select. Higher weights indicate higher priority when comparing NodePools.
  # Specifying no weight is equivalent to specifying a weight of 0.
  weight: 10
#status:
#  conditions:
#    - type: Initialized
#      status: "False"
#      observedGeneration: 1
#      lastTransitionTime: "2024-02-02T19:54:34Z"
#      reason: NodeClaimNotLaunched
#      message: "NodeClaim hasn't succeeded launch"
#  resources:
#    cpu: "20"
#    memory: "8192Mi"
#    ephemeral-storage: "100Gi"
