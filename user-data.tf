# Copyright (c) 2019, 2021, Oracle Corporation and/or affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

data "template_file" "backstage_cloud_config" {
  template = <<YAML
#cloud-config
packages:
 - dnf-utils
 - zip
 - unzip
 - git

write_files:
- content: |
    [Unit]
    Description=backstage_start
    [Service]
    Type=simple
    Restart=always
    RestartSec=15
    User=opc
    ExecStart=/bin/bash -c "yarn dev"
    WorkingDirectory=/home/opc/backstage
    [Install]
    WantedBy=multi-user.target
  owner: root:root
  path: /etc/systemd/system/backstage.service
  permissions: '0755'

runcmd:
 - echo '********************** setup firewalld ***************************************'
 - /bin/firewall-offline-cmd --add-port=3000/tcp
 - /bin/firewall-offline-cmd --add-port=7007/tcp
 - systemctl enable firewalld
 - systemctl restart firewalld
 - echo '********************** run dnf ***********************************************'
 - dnf group install -y  "Development Tools"
 - dnf module -y install nodejs:14 
 - echo '********************** install yarn ******************************************'
 - npm install --global yarn
 - su opc -c "git -C /home/opc/ clone --depth 1 https://github.com/backstage/backstage.git"
 - echo '********************** run yarn **********************************************'
 - su opc -c 'cd /home/opc/backstage && /usr/local/bin/yarn'
 - echo '********************** run yarn tsc ******************************************'
 - su opc -c "cd /home/opc/backstage && export NODE_OPTIONS=--max-old-space-size=8192 && /usr/local/bin/yarn tsc"
 - echo '********************** run yarn build ****************************************'
 - su opc -c "cd /home/opc/backstage && /usr/local/bin/yarn build"
 - echo '********************** setup backstage app ***********************************'
 - su opc -c "cp /home/opc/backstage/app-config.yaml /home/opc/backstage/app-config.yaml.orig"
 - echo $(oci-public-ip -g) | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' > /tmp/my_ip
 - sed -i -e "s/Backstage Example App/Backstage App on OCI/" /home/opc/backstage/app-config.yaml
 - sed -i -E "s/(baseUrl.{2})http:\/\/localhost:3000/\1http:\/\/0.0.0.0:3000/" /home/opc/backstage/app-config.yaml
 - export MY_IP="$(cat /tmp/my_ip)" && sed -i -E "s/(baseUrl.{2})http:\/\/localhost:7007/\1http:\/\/$MY_IP:7007/" /home/opc/backstage/app-config.yaml
 - export MY_IP="$(cat /tmp/my_ip)" && sed -i -E "s/(origin.{2})http:\/\/localhost:3000/\1http:\/\/$MY_IP:3000/" /home/opc/backstage/app-config.yaml
 - echo '********************** start backstage **************************************'
 - systemctl daemon-reload && systemctl enable backstage && systemctl start backstage
 - echo '********************** backstage setup completed! ***************************'
YAML
}
