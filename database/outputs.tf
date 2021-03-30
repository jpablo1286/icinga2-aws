output "db_endpoint" {
  value = aws_db_instance.icinga2_db.endpoint
}
output "db_host" {
  value = aws_db_instance.icinga2_db.address
}