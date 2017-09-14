#!/bin/sh

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
EOF
