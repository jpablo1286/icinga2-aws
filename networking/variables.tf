variable "vpc_cidr" {
  type = string
}
variable "icinga_cidrs" {
  type = list(any)
}
variable "private_cidrs" {
  type = list(any)
}
variable "icinga_sn_count" {
  type = number
}
variable "private_sn_count" {
  type = number
}
variable "max_subnets" {
  type = number
}
variable "security_groups" {}
variable "db_subnet_group" {
  type = bool
}
