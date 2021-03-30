data "aws_availability_zones" "available" {}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "aws_vpc" "icinga2_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "icinga2_vpc-${random_integer.random.id}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "icinga2_subnet_public" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.icinga2_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_list.result[count.index]
  tags = {
    Name = "icinga2_public_${count.index + 1}"
  }
}

resource "aws_route_table_association" "icinga2_assoc" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.icinga2_subnet_public.*.id[count.index]
  route_table_id = aws_route_table.icinga2_rt.id
}
resource "aws_subnet" "icinga2_subnet_private" {
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.icinga2_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = random_shuffle.az_list.result[count.index]
  tags = {
    Name = "icinga2_private_${count.index + 1}"
  }
}

resource "aws_internet_gateway" "icinga2_gateway" {
  vpc_id = aws_vpc.icinga2_vpc.id
  tags = {
    Name = "icinga2_igw"
  }
}

resource "aws_route_table" "icinga2_rt" {
  vpc_id = aws_vpc.icinga2_vpc.id
  tags = {
    Name = "icinga2_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.icinga2_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.icinga2_gateway.id
}

resource "aws_default_route_table" "icinga2_private_rt" {
  default_route_table_id = aws_vpc.icinga2_vpc.default_route_table_id
  tags = {
    Name = "icinga2_private"
  }
}

resource "aws_security_group" "icinga2_sg" {
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.icinga2_vpc.id
  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      cidr_blocks      = ingress.value.cidr_blocks
      description      = ""
      from_port        = ingress.value.from
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = ingress.value.protocol
      security_groups  = []
      self             = false
      to_port          = ingress.value.to
    }
  }
  egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Outgoing"
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }]
}

resource "aws_db_subnet_group" "icinga2_rds_subnetgroup" {
  count = var.db_subnet_group ? 1 : 0
  name = "icinga2_rds_subnetgroup"
  subnet_ids = aws_subnet.icinga2_subnet_private.*.id
  tags = {
      Name = "icinga2_rds_sng"
  }
}
