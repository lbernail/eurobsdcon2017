#!/bin/sh

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

# Starting daemons at first boot
rcctl enable consul

cat >> /etc/rc.firsttime <<EOF
echo -n "starting"
rcctl start consul
echo
EOF
