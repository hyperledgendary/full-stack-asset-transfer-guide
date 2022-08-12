# Select a Kubernetes Cluster

[PREV: Setup](00-setup.md) <==> [NEXT: Deploy Fabric](20-fabric.md)

---

Runtime                              | Where is k8s?      | Where is kubectl?     | Fabric Client       | When to use?
-------------------------------------|--------------------|-----------------------|---------------------|-----------------------------
[KIND](11-kube-kind.md)              | localhost          | localhost             | localhost           | > 7CPU / 8GRAM; Mac or WSL2
[multipass VM](12-kube-multipass.md) | VM on localhost    | localhost or VM       | localhost           | Windows; non-WSL2 
[EC2 VM](13-kube-ec2-vm.md)          | VM on AWS EC2      | VM                    | localhost           | Pre-provisioned
EKS / IKS                            | Cloud Provider     | localhost             | localhost           | Facilitator provisioned