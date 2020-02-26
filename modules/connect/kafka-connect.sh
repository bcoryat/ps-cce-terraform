#!/bin/bash

########### Update and Install ###########

apt update -y
apt install wget -y
apt install unzip -y
apt install openjdk-8-jdk-headless -y

########### Initial Bootstrap ###########
wget -qO - https://packages.confluent.io/deb/5.3/archive.key | apt-key add -
add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/5.3 stable main" -y
apt update
apt install confluent-platform-2.12 -y

########### Generating Props File ###########

cd /etc/kafka
mv connect-distributed.properties connect-distributed.properties.orig

cat > connect-distributed.properties <<- "EOF"
${kafka_connect_properties}
EOF

systemctl enable confluent-kafka-connect
systemctl start confluent-kafka-connect