module "networking" {
  source = "./networking"
  vpc_cidr = local.vpc_cidr
  security_groups = local.security_groups
  icinga_sn_count = 2
  private_sn_count = 3
  max_subnets = 20
  icinga_cidrs = [for i in range(1,255,2): cidrsubnet(local.vpc_cidr,8,i)]
  private_cidrs = [for i in range(2,255,2): cidrsubnet(local.vpc_cidr,8,i)]
  db_subnet_group = true
}

module "database" {
  source = "./database"
  db_storage = 10
  db_engine_version = "5.7.22"
  db_instance_class = "db.t2.micro"
  dbname = var.dbname
  dbuser = var.dbuser
  dbpassword = var.dbpassword
  db_identifier = "icinga-db"
  skip_db_snapshot = true
  db_subnet_group_name = module.networking.db_subnet_group_name[0]
  db_vpc_security_group_ids= module.networking.db_security_group
}

module "loadbalancing" {
  source = "./loadbalancing"
  icinga_sg  = module.networking.icinga_sg
  icinga_subnets = module.networking.icinga_subnets
  vpc_id = module.networking.vpc_id
  tg_port = 80
  tg_protocol = "HTTP"
  lb_healthy_threshold = 2
  lb_unhealthy_threshold = 2
  lb_timeout = 3
  lb_interval = 30
  listener_port = 80
  listener_protocol = "HTTP"
}

module "compute" {
  source = "./compute"
  icinga_sg = module.networking.icinga_sg
  icinga_subnets = module.networking.icinga_subnets
  instance_count = 1
  instance_type = "t3.micro"
  vol_size = 10
  key_name = "icinga2_key"
  public_key_path = "${path.root}/keys/aws.pem.pub"
  priv_key_path = "${path.root}/keys/aws.pem"
  db_endpoint = module.database.db_endpoint
  dbuser = var.dbuser
  dbpassword = var.dbpassword
  dbname = var.dbname
  dbhost = module.database.db_host
  user_data_path = "${path.root}/userdata.tpl"
  lb_target_group_arn = module.loadbalancing.lb_target_group_arn
  tg_port = 80
  vpc_cidr = local.vpc_cidr
}