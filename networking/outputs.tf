output "vpc_id" {
  value = aws_vpc.icinga2_vpc.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.icinga2_rds_subnetgroup.*.name
}

output "db_security_group" {
  value = [aws_security_group.icinga2_sg["rds"].id]
}

output "icinga_sg" {
  value = aws_security_group.icinga2_sg["icinga"].id
}

output "icinga_subnets" {
  value = aws_subnet.icinga2_subnet_public.*.id
}