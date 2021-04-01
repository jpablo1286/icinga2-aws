data "aws_ami" "server_ami" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-2.0.2021*-x86_64-gp2"]
    }
}

resource "random_id" "icinga2_node_id" {
    byte_length = 2
    count = var.instance_count
    keepers = {
        key_name = var.key_name
    }
}

resource "aws_key_pair" "ssh_auth" {
  key_name = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "icinga2_node" {
  count = var.instance_count
  instance_type = var.instance_type
  ami = data.aws_ami.server_ami.id
  tags = {
      Name = "icinga2-node-${random_id.icinga2_node_id[count.index].dec}"
  }
  key_name = aws_key_pair.ssh_auth.id
  vpc_security_group_ids = [var.icinga_sg]
  subnet_id = var.icinga_subnets[count.index]
  user_data = templatefile(var.user_data_path,{
      nodename = "icinga2-node-${random_id.icinga2_node_id[count.index].dec}"
  })
  root_block_device {
      volume_size = var.vol_size

  }
  connection {
          type = "ssh"
          user = "ec2-user"
          host = self.public_ip
          private_key = file(var.priv_key_path)
  }
  provisioner "file" {
    source      = "${path.cwd}/mysql-check.sh"
    destination = "/tmp/mysql-check.sh"
  }

  provisioner "remote-exec" {  
    inline = [
      "chmod +x /tmp/mysql-check.sh",
      "/tmp/mysql-check.sh ${var.dbhost} ${var.dbname} ${var.dbuser} ${var.dbpassword}" ,
    ]
  }

  provisioner "local-exec" {
    working_dir = "${path.cwd}/ansible/"
    command = "export ANSIBLE_HOST_KEY_CHECKING=False && ansible-playbook -u ec2-user --key-file ${path.cwd}/${var.priv_key_path} --extra-vars 'mysql_user=${var.dbuser} mysql_password=${var.dbpassword} mysql_host=${var.dbhost}' -i ${self.public_ip}, main.yml"
  }

}

resource "aws_lb_target_group_attachment" "icinga2_tg_attach" {
  count = var.instance_count
  target_group_arn = var.lb_target_group_arn
  target_id = aws_instance.icinga2_node[count.index].id
  port = var.tg_port
}

