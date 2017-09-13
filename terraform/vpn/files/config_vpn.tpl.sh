#!/bin/sh

hostname ${TF_CONSUL_HOSTNAME}

# Consul
pkg_add consul

cat > /etc/consul.d/config.json <<EOF
{
    "bootstrap_expect": ${TF_CONSUL_SERVERS},
    "server": ${TF_CONSUL_SERVERROLE},
    "client_addr": "${TF_CONSUL_BIND_IP}",
    "ui": ${TF_CONSUL_UI},
    "enable_syslog": true,
    "data_dir": "/var/consul",
    "retry_join_ec2" :
        {
            "tag_key": "ConsulCluster",
            "tag_value": "${TF_CONSUL_EC2_TAG}"
        }
}
EOF

rcctl enable consul
rcctl start consul


# Consul template
pkg_add consul-template

cat > /etc/consul-template.d/sample.conf << EOF
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
chown _consul-template:_consul-template /etc/consul-template.d/sample.conf


# Template
cat > /etc/consul-template.d/sample.ctmpl << EOF
Hello {{ key_or_default "name" "charlie" -}}
EOF
chown _consul-template:_consul-template /etc/consul-template.d/sample.ctmpl

rcctl enable consul_template
rcctl set consul_template flags -config /etc/consul-template.d/sample.conf
rcctl start consul_template
