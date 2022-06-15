provider "alicloud" {
  region = "cn-hangzhou"
}

resource "alicloud_vpc" "default" {
  vpc_name = var.vpc_name
  cidr_block = var.cidr_block
}

resource "alicloud_vswitch" "default" {
  vpc_id = alicloud_vpc.default.id 
  cidr_block = var.cidr_block
  zone_id = var.zone
}

resource "alicloud_security_group" "default" {
  name = var.sg_name
  vpc_id = alicloud_vpc.default.id
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_eip_address" "eip" {
}

resource "alicloud_eip_association" "eip_asso" {
  count                = var.instance_number
  allocation_id = alicloud_eip_address.eip.id
  instance_id   = alicloud_instance.web[count.index].id
}


resource "alicloud_ecs_key_pair" "default" {
  key_pair_name = var.key_name
  public_key    = var.public_key
}

resource "alicloud_instance" "web" {
  count                = var.instance_number
  availability_zone = var.zone
  security_groups = alicloud_security_group.default.*.id
  instance_type        = "ecs.t5-lc1m1.small"
  system_disk_category = "cloud_efficiency"
  image_id             = "ubuntu_18_04_64_20G_alibase_20190624.vhd"
  instance_name        = var.instance_name

  key_name   = alicloud_ecs_key_pair.default.key_pair_name
  vswitch_id = alicloud_vswitch.default.id

  internet_max_bandwidth_out = 1
}
