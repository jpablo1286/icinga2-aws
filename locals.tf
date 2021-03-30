locals {
  vpc_cidr = "10.15.0.0/16"
}
locals {
    security_groups = {
        public = {
            name = "public_sg"
            description = "Public"
            ingress = {
                ssh = {
                    from = 22
                    to = 22
                    protocol = "tcp"
                    cidr_blocks = var.access_ip
                },
                http = {
                    from = 80
                    to = 80
                    protocol = "tcp"
                    cidr_blocks = var.access_ip
                },
                icinga2 = {
                    from = 5665
                    to = 5665
                    protocol = "tcp"
                    cidr_blocks = var.icinga_ips
                }
            }
        },
        rds = {
            name = "rds_sg"
            description = "RDS"
            ingress = {
                mysql = {
                    from = 3306
                    to = 3306
                    protocol = "tcp"
                    cidr_blocks = [local.vpc_cidr]
                }
            }
        }
    }
}