# Terraform cost estimate (hourly)

Rough **hourly** cost for the resources created by this Terraform in **eu-west-1**. Prices are indicative (On-Demand, no Reserved/Savings Plans).

| Resource | Quantity | $/hour (eu-west-1) | Notes |
|----------|----------|--------------------|--------|
| **EKS control plane** | 1 cluster | **$0.10** | [EKS pricing](https://aws.amazon.com/eks/pricing/) – flat per cluster |
| **EC2 (node group)** | 1 × t3.small (default) | **~$0.021** | [EC2 On-Demand](https://aws.amazon.com/ec2/pricing/on-demand); 2 vCPU, 2 GiB RAM |
| **NAT Gateway** | 1 (single_nat_gateway) | **$0.045** | [VPC pricing](https://aws.amazon.com/vpc/pricing/) – plus $0.045/GB data processed |
| **S3 (data bucket)** | 1 bucket | **~$0** | Pay per storage + requests; negligible until you store a lot |
| **VPC / subnets** | — | **$0** | No hourly charge |

**Total baseline: ~\$0.17/hour** (with 1 node and minimal NAT traffic).

- **Per month (24/7):** ~\$0.17 × 730 ≈ **~\$124/month** before NAT data processing.
- **If node group scales to 3 × t3.small:** add ~\$0.042/hr (2 more nodes) → ~\$0.21/hr.
- **NAT data:** Add $0.045 per GB processed through the NAT (e.g. pulls to nodes, outbound from private subnets).

Bootstrap (S3 state bucket, no DynamoDB) adds only small S3 storage/request costs. ArgoCD runs on the EKS nodes, so no extra infra cost.

**Ways to reduce cost:** Use Spot for the node group, turn the cluster off when not needed (e.g. dev), or use a smaller/cheaper NAT setup (e.g. NAT instances – not in this Terraform).
