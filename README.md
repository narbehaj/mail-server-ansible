# Simple Postfix and Dovecot Ansible

This repo simply automates the installation of Postfix and Dovecot on an Openstack instance. The terraform will create an instance. Then it will point the NS names and create MX record in Name.com to the newly created instance's public IP.

### Terraform and Name.com

Simply edit the `variables.tf` and run:

```bash
$ cd terraform && terraform init
$ terraform plan
$ terraform apply
```

Terraform will give you the IP address, put it in to `ansible/hosts.ini` under `[mail-srv]` and run the ansible.
If you want to skip the Terraform part, simply update the `ansible/hosts.ini` with your server's IP address.

### Ansible

Check the `ansible/roles/mail-server/vars/main.yml` and configure with your choice of values. 
You also have to put your SSL private key and certificate key under `ansible/roles/mail-server/files`.

```bash
$ cd ansible
$ ansible-playbook mail.yml
```

You will receive and email if the ansible works well :)
