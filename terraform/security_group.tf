resource "openstack_networking_secgroup_v2" "narbeh-mail" {
  name = var.security_group_name
}

resource "openstack_networking_secgroup_rule_v2" "instance_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.narbeh-mail.id
}

resource "openstack_networking_secgroup_rule_v2" "instance_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.narbeh-mail.id
}
