#!/bin/bash

########### Update and Install ###########
add-apt-repository -y ppa:vbernat/haproxy-1.8
apt-get update -y
apt-get install -y haproxy

########### Generating Configuration###########

cd /etc/haproxy

rm haproxy.cfg
cat > haproxy.cfg <<- "EOF"
${haproxy_cfg}
EOF

########### Restart the service ############
systemctl restart haproxy