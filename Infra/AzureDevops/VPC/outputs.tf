output "vpc_id" {
  value = module.vpc.default_vpc_id
}

output "vpc_name" {
  value = module.vpc.name
}

output "nats" {
  value = module.vpc.natgw_ids
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets_cidr_blocks" {
  value = module.vpc.public_subnets_cidr_blocks
}

output "public_internet_gateway_route_id" {
  value = module.vpc.public_internet_gateway_route_id
}

output "vpc_owner_id" {
  value = module.vpc.vpc_owner_id
}

# vpc_id                   = "vpc-06e2765871c16a6a4"
#   subnet_ids               = ["subnet-09eac11fbe83da104", "subnet-09eac11fbe83da104", "subnet-09eac11fbe83da104"]
#   control_plane_subnet_ids = ["subnet-09eac11fbe83da104", "subnet-09eac11fbe83da104", "subnet-09eac11fbe83da104"]