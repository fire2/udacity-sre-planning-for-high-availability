output "account_id" {
 value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
 value = data.aws_caller_identity.current.arn
}

output "caller_user" {
 value = data.aws_caller_identity.current.user_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "db_cluster_id" {
  value = module.project_rds_p.db_cluster_arn
}