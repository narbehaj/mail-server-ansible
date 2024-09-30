resource "openstack_compute_instance_v2" "narbeh-mail" {
  name            = "${var.vm_name_prefix}"
  image_id        = data.openstack_images_image_v2.image.id
  flavor_name     = var.flavor_name
  key_pair        = openstack_compute_keypair_v2.narbeh-ssh.name
  security_groups = ["${openstack_networking_secgroup_v2.narbeh-mail.name}"]

  network {
    name = var.network
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "openstack_networking_floatingip_v2" "float_ip" {
  pool = var.external_network
}

resource "openstack_compute_floatingip_associate_v2" "float_ip_associate" {
  floating_ip = openstack_networking_floatingip_v2.float_ip.address
  instance_id = openstack_compute_instance_v2.narbeh-mail.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "openstack_compute_keypair_v2" "narbeh-ssh" {
  name       = var.ssh_key_name
  public_key = var.ssh_key
}

# Set NS records

resource "namecom_nameservers" "mail-domain" {
  zone = var.domain_name
  nameservers = [
    "${openstack_networking_floatingip_v2.float_ip.address}",
  ]
}

# Set MX record

resource "namecom_record" "mail-domain" {
  zone   = var.domain_name
  host   = "mail"
  type   = "MX"
  answer = "${openstack_networking_floatingip_v2.float_ip.address}"
}

output "narbeh-mail" {
  value = openstack_networking_floatingip_v2.float_ip.address
}