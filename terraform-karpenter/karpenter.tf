resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = <<YAML
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: ai-compute-class
spec:
  amiFamily: AL2023
  role: KarpenterNodeRole-ai-cluster
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "ai-platform-cluster"
  securityGroupSelectorTerms:
    - tags:
        kubernetes.io/cluster/ai-platform-cluster: "owned"
  tags:
    Intent: "AI-Inference-Workloads"
    CostCenter: "SRE-Operations"
YAML
}

resource "kubectl_manifest" "karpenter_node_pool" {
  depends_on = [kubectl_manifest.karpenter_node_class]
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: ai-compute-pool
spec:
  template:
    spec:
      requirements:
        - key: "karpenter.k8s.aws/instance-family"
          operator: In
          values: ["g4dn", "g5", "c6i"]
        - key: "karpenter.sh/capacity-type"
          operator: In
          values: ["on-demand"]
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: ai-compute-class
  limits:
    cpu: 128
    memory: 256Gi
  disruption:
    consolidationPolicy: WhenUnderutilized
    consolidateAfter: 30s
    expireAfter: 720h
YAML
}