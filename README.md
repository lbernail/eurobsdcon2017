This repository contains the code of the demo I gave at EuroBSDcon Paris 2017. The slides are available here: [https://www.slideshare.net/lbernail/discovering-openbsd-on-aws](https://www.slideshare.net/lbernail/discovering-openbsd-on-aws).

## Start an  Openbsd instance
Search for OpenBSD in the community AMIs, and pick the latest one (for 6.1 in Ireland, this is ami-17110571 as of 2017-09-23)
## Connect
```console
ssh ec2-user@<public-ip>
```

## How did my key get there?
```console
ftp -MVo - http://169.254.169.254/latest/meta-data
ftp -MVo - http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key
```

## When is it executed?
Very early in the boot process when interface xfn0 comes up
```console
cat /etc/hostname.xnf0
cat /usr/local/libexec/ec2-init
```

## What permissions do I have?
```console
doas cat /etc/doas.conf
```

## Install terraform
```console
pkg_info -Q terraform
doas pkg_add terraform
```

## Install Git and clone demo repository
```console
doas pkg_add git
git clone git@github.com:lbernail/eurobsdcon2017.git
```

## Create VPC
First, copy AWS credentials to the OpenBSD machine or export your access key/secret key. Then adapt the terraform.tfvars file to reference a key pair you own.  
In addition, the three terraform stacks use remote states to get information from the other ones. To make it work, adapt the bucket in the main.tf of each directory (both for terraform and for remote states data sources)
```console
cd eurobsdcon2017/terraform/vpc
terraform init
terraform plan
terraform apply
```
You can verify in the AWS console that the VPC has been created (or is under creation)

## Create the Consul cluster
```console
cd ../consul
terraform init
terraform apply
```

## ssh to bastion host, and tunnel traffic to access agent UI
```console
ssh ec2-user@<bastion ip> -L 8500:10.0.128.200:8500
```
You can connect to the UI: http://localhost:8500

## Connect to a consul instance (from the bastion)
```console
ssh 10.0.128.100
consul members
```

# Consul configuration (user-data)
```console
ftp -MVo - http://169.254.169.254/latest/user-data
```
You can look at the tags on the instance (used for discovery), their IAM role (giving them permission to use the AWS describe-instance API), and user-data


## Build VPN
Adapt the terraform.tfvars to reference a key pair on your account and an Elastic IP you own (or remove the eip attachement from terraform and simply use the public IP given by AWS to configure the other end of the VPN)
```console
cd ../vpn
terraform init
terraform apply
```

## Connect from bastion and look at the server configuration
```console
ssh 10.0.0.10
ftp -MVo - http://169.254.169.254/latest/user-data
consul members
rcctl check consul consul_template
cat /etc/consul-template.d/default.conf
doas cat /etc/ipsec.conf
```

## Build remote end of VPN
If you have a VPN endpoint you can connect to it. Otherwise, create a VPN connection in AWS in another VPC (using the public ip from the VPN instance), configure AWS routing to use the vgw for the IP range of the VPC you built earlier (10.0.0.0/16 if you haven't changed it) and start an instance in this remote VPC (allowing ICMP from your VPC).  

## Add keys to consul
You can use the UI or the API from Consul (from your machine after port forwading):
```console
curl -X PUT -d '<remote CIDR>' http://localhost:8500/v1/kv/vpn/<name>/cidrblock
curl -X PUT -d '<remote endpoint>' http://localhost:8500/v1/kv/vpn/<name>/endpoint
curl -X PUT -d '<PSK>' http://localhost:8500/v1/kv/vpn/<name>/psk
```

## Look at the ipsec configuration, and try pinging
```console
doas cat /etc/ipsec.conf
ping <host on the other side of the VPN>
doas ipsecctl -s all
```
