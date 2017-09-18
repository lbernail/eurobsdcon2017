#!/bin/sh

# Enabling ipsec
rcctl enable ipsec
rcctl enable isakmpd
rcctl set isakmpd flags -K

touch /etc/ipsec.conf
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
consul {
  address = "127.0.0.1:8500"
  retry {
    enabled  = true
    attempts = 10
    backoff  = "1s"
  }
}

syslog {
  enabled  = true
  facility = "DAEMON"
}

template {
  source      = "/etc/consul-template.d/ipsec.ctmpl"
  destination = "/etc/ipsec.conf"
  perms       = 0600
  command     = "ipsecctl -f /etc/ipsec.conf || echo Invalid ipsec configuration"
}
EOF

# Template
cat > /etc/consul-template.d/ipsec.ctmpl << 'EOF'
{{ range tree "vpn" | explode -}}
{{ if and .cidrblock .endpoint .psk -}}
ike esp from ${TF_VPC_CIDR} to {{ .cidrblock }} \
        peer {{ .endpoint }} \
        srcid ${TF_EIP} \
        psk "{{ .psk }}"
{{ end -}}
{{ end }}
EOF
chown _consul-template:_consul-template /etc/consul-template.d/ipsec.ctmpl

# Enabling and  daemons at first boot
rcctl enable consul consul_template
rcctl set consul_template user root

cat >> /etc/rc.firsttime <<EOF
echo -n "starting"
rcctl start consul consul_template isakmpd
echo
EOF
