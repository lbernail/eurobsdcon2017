#!/bin/sh

eip=$(ftp -MVo - http://169.254.169.254/latest/meta-data/public-ipv4)

# Enabling ipsec
rcctl enable ipsec
rcctl enable isakmpd
rcctl set isakmpd flags -K

cat > /etc/ipsec.conf <<EOF
ike esp from ${TF_VPC_CIDR} to 172.30.0.0/16 \\
        peer 34.196.141.208 \\
        srcid $eip \\
        psk "m8f6xweKU3TsIJgmN4t9z9Uq728mL48Z"
EOF
chmod 600 /etc/ipsec.conf

# Consul
pkg_add consul

cat > /etc/consul.d/config.json <<EOF
{
    "bootstrap_expect": ${TF_CONSUL_SERVERS},
    "server": ${TF_CONSUL_SERVERROLE},
    "client_addr": "${TF_CONSUL_BIND_IP}",
    "node_name": "${TF_CONSUL_HOSTNAME}",
    "ui": ${TF_CONSUL_UI},
    "enable_syslog": true,
    "disable_update_check": true,
    "data_dir": "/var/consul",
    "retry_join_ec2" :
        {
            "tag_key": "ConsulCluster",
            "tag_value": "${TF_CONSUL_EC2_TAG}"
        }
}
EOF

# Consul template
pkg_add consul-template

cat > /etc/consul-template.d/default.conf << EOF
consul = "127.0.0.1:8500"

syslog {
  enabled  = true
    facility = "DAEMON"
}

template {
  source      = "/etc/consul-template.d/sample.ctmpl"
  destination = "/etc/consul-template.d/sample.txt"
}
EOF

# Template
cat > /etc/consul-template.d/sample.ctmpl << EOF
Hello {{ key_or_default "name" "charlie" -}}
EOF
chown _consul-template:_consul-template /etc/consul-template.d/sample.ctmpl

# Enabling and  daemons at first boot
rcctl enable consul consul_template

cat >> /etc/rc.firsttime <<EOF
echo -n "starting"
rcctl start consul consul_template
echo
echo -n "starting"
rcctl start isakmpd
echo
ipsecctl -f /etc/ipsec.conf
echo
EOF
