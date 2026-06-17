# BMC Prod Live AWS to Terraform Mapping

Generated from read-only AWS CLI calls using `AWS_PROFILE=ukpfms` in `ap-south-1`.
No AWS resources were changed while collecting this mapping.

## Core

| Terraform address | Live AWS ID / value |
| --- | --- |
| `module.network.aws_vpc.vpc` | `vpc-06f124d2f8467d608` |
| `module.network.aws_internet_gateway.internet_gateway` | `igw-0c8dc56a455fb83cd` |
| `module.network.aws_eip.eip` | `eipalloc-06ea78d241c6b2a6c` / `13.202.223.188` |
| `module.network.aws_nat_gateway.nat` | `nat-0fd063b44fd0c038f` |
| `module.network.aws_route_table.public_route_table` | `rtb-01de28c365c5af6ce` |
| `module.network.aws_route_table.private_route_table` | `rtb-02f0e1766ece1eb1e` |
| `module.network.aws_security_group.rds_db_sg` | `sg-08f9979782517f88a` |

## Subnets

| Terraform address | Live subnet | AZ | CIDR |
| --- | --- | --- | --- |
| `module.network.aws_subnet.public_subnet[0]` | `subnet-06a60ab454b59bf8c` | `ap-south-1b` | `192.168.0.0/21` |
| `module.network.aws_subnet.public_subnet[1]` | `subnet-0815ae92f8aaa20da` | `ap-south-1a` | `192.168.8.0/21` |
| `module.network.aws_subnet.private_subnet[0]` | `subnet-02fec7d5efae0f94b` | `ap-south-1b` | `192.168.64.0/19` |
| `module.network.aws_subnet.private_subnet[1]` | `subnet-0fd8b9280870ed0e1` | `ap-south-1a` | `192.168.96.0/19` |

## Route Table Associations

| Terraform address | Live association | Subnet |
| --- | --- | --- |
| `module.network.aws_route_table_association.public[0]` | `rtbassoc-068d183c632f966e7` | `subnet-06a60ab454b59bf8c` |
| `module.network.aws_route_table_association.public[1]` | `rtbassoc-074463db1df48d492` | `subnet-0815ae92f8aaa20da` |
| `module.network.aws_route_table_association.private[0]` | `rtbassoc-02934096655cf1bea` | `subnet-02fec7d5efae0f94b` |
| `module.network.aws_route_table_association.private[1]` | `rtbassoc-0a38a2eca33465259` | `subnet-0fd8b9280870ed0e1` |

## EKS

| Terraform address / variable | Live AWS ID / value |
| --- | --- |
| `module.eks.aws_eks_cluster.this[0]` | `bmc-prod` |
| `var.kubernetes_version` | `1.34` |
| `var.cluster_authentication_mode` | `CONFIG_MAP` |
| `var.cluster_service_ipv4_cidr` | `10.100.0.0/16` |
| `var.eks_cluster_role_arn` | `arn:aws:iam::713626956440:role/bmc-prod2025012208434463150000000c` |
| `var.eks_cluster_security_group_id` | `sg-07b503a66e1e1023c` |
| `var.eks_node_security_group_id` | `sg-072f13c3d135db248` |
| `var.eks_legacy_worker_security_group_id` | `sg-05ab7cdde5b9d09bb` |
| `aws_eks_node_group.bmc_managed_m5a_xlarge_1b` | `bmc-prod:bmc-managed-m5a-xlarge-1b` |
| `var.eks_managed_node_role_arn` | `arn:aws:iam::713626956440:role/bmc-prod-managed-node-role` |

## EKS Addons

| Terraform address | Live version |
| --- | --- |
| `aws_eks_addon.vpc_cni` | `v1.21.1-eksbuild.3` |
| `aws_eks_addon.aws_ebs_csi_driver` | `v1.55.0-eksbuild.1` |
| `aws_eks_addon.kube_proxy` | `v1.34.3-eksbuild.2` |
| `aws_eks_addon.core_dns` | `v1.13.1-eksbuild.1` |

## RDS

| Terraform address / variable | Live AWS ID / value |
| --- | --- |
| `module.db.aws_db_instance.rds_postgres` | `bmc-prod-db` |
| `module.db.aws_db_subnet_group.db_subnet_group` | `db-subnet-group-bmc-prod` |
| `var.db_instance_class` | `db.r6i.large` |
| `var.db_engine_version` | `14.22` |
| `var.db_storage_gb` | `100` |
| `var.db_storage_type` | `gp2` |
| `var.db_backup_retention_days` | `15` |
| `var.db_parameter_group_name` | `postgres14-md5-auth` |
| `var.db_deletion_protection` | `true` |
| `var.db_cloudwatch_logs_exports` | `["postgresql", "iam-db-auth-error"]` |

## Static EBS Volumes Managed By Storage Modules

| Terraform address | Live volume | Size | Type | AZ |
| --- | --- | --- | --- | --- |
| `module.es-master.aws_ebs_volume.vol[0]` | `vol-077dc85d2062ef2d5` | `25` | `gp3` | `ap-south-1b` |
| `module.es-master.aws_ebs_volume.vol[1]` | `vol-043c5c4c8575168cc` | `25` | `gp3` | `ap-south-1b` |
| `module.es-master.aws_ebs_volume.vol[2]` | `vol-0b0a31297eb752a1f` | `25` | `gp3` | `ap-south-1b` |
| `module.es-data-v1.aws_ebs_volume.vol[0]` | `vol-0cdecdc08f993a69d` | `100` | `gp3` | `ap-south-1b` |
| `module.es-data-v1.aws_ebs_volume.vol[1]` | `vol-0865c7d10068f133d` | `100` | `gp3` | `ap-south-1b` |
| `module.es-data-v1.aws_ebs_volume.vol[2]` | `vol-0cfb061b4b6013ad5` | `100` | `gp3` | `ap-south-1b` |
| `module.zookeeper.aws_ebs_volume.vol[0]` | `vol-0e2d3ec0a0d0d3668` | `20` | `gp3` | `ap-south-1b` |
| `module.zookeeper.aws_ebs_volume.vol[1]` | `vol-0dd758dcead218342` | `20` | `gp3` | `ap-south-1b` |
| `module.zookeeper.aws_ebs_volume.vol[2]` | `vol-01c71946c83d30348` | `20` | `gp3` | `ap-south-1b` |
| `module.kafka.aws_ebs_volume.vol[0]` | `vol-0bfe5c05cead8e7e9` | `200` | `gp3` | `ap-south-1b` |
| `module.kafka.aws_ebs_volume.vol[1]` | `vol-08488c43f88c77056` | `200` | `gp3` | `ap-south-1b` |
| `module.kafka.aws_ebs_volume.vol[2]` | `vol-08f31d6f1b0fecbb2` | `200` | `gp3` | `ap-south-1b` |

## Not Managed In This Terraform Root

The following EBS volumes are dynamically provisioned Kubernetes PVC volumes. They should stay managed by Kubernetes/EBS CSI, not by this static Terraform storage module:

- `vol-0fe0f4c99f786e81a` - `pgadmin-data`
- `vol-0d9182638178703eb` - Prometheus data
- `vol-0c748eaf07f25754b` - PMM storage
- `vol-0bddcb0122b66d1c0` - Grafana
- `vol-0198f1a7a797b4ce4` - Loki storage

## State Reconciliation

State was reconciled on 2026-06-17 with state-only operations and a refresh-only apply. A final dry-run plan returned: `No changes. Your infrastructure matches the configuration.`

The EKS CloudWatch log group `/aws/eks/bmc-prod/cluster` exists in AWS but is intentionally not tracked in this Terraform root because the upstream EKS module cannot represent the live untagged, no-retention log group without planning tag/retention updates.
