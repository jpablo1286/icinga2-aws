# icinga2-aws
This repository contains terraform modules and ansible playbooks in order to deploy an icinga2 master node with icingaweb2 runing in ec2 instance (Amazon Linux) and database deployed in RDS. This throught an LB.

**VPC cidr**

Cidr for the icinga2 VPC can be defined in locals.tf
```
locals {
  vpc_cidr = "x.x.x.x/x"
} 
```
**Security Groups:**

Security groups are defined in locals.tf by default there are 2 secuirty groups "icinga" and "rds", "icinga" sets access to icinga master for port 22,80 and 5665, and "rds" sets access to rds instance.
In terraform.tfvars there 2 vars, first one for set admin access "access_ip" and other one for set icinga agent access "icinga_ips"

**Templates:**

There are 2 templates for define required variables, one for terraform and other for ansible (terraform.tfvars.template and ansible/mysql.vars.yml.template) for deploy this terraform is needed to rename this files (removing .template extension) and set the variables with your own values.

**Usage:**

After set the variables files you only need to run terraform as usual.
```
terraform init
terraform plan
terraform apply --auto-approve
```
once finish in the output you will get the LB fqdn so you can browse to /icingaweb2 and authenticate using default user "admin" with default password "admin" it need to be changed ASAP.