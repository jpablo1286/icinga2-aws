variable "aws_region" {
  default = "us-west-2"
}
variable "access_ip" {}
variable "icinga_ips" {}
#----database -----
variable "dbname" {
  type = string
}
variable "dbpassword" {
  type = string
}
variable "dbuser" {
  type = string
}
