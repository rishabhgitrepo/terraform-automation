locals {
  vpc_name_local = "${var.vpc_name}-cndinfotech"
  web_server     = "${var.web_server_name}-cndinfotech"
  bastion_host   = "${var.vpc_name}-bastion-host-cndinfotech"
}