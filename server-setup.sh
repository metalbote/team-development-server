#!/usr/bin/env bash

yum update && yum upgrade
yum install epel-release
yum install mc net-tools open-vm-tools wget yum-utils vim cockpit cockpit-packagekit cockpit-storaged cockpit-system git samba-client samba-common cifs-utils httpd-tools
yum group install "Development Tools"
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install docker-ce docker-compose cockpit-docker
export kernel_headers=`ls -hd /usr/src/kernels/3*`
sudo ln -s ${kernel_headers}/include/generated/uapi/linux/version.h ${kernel_headers}/include/linux/version.h
sudo yum install "kernel-devel-uname-r == $(uname -r)"

sudo systemctl enable docker.service
sudo systemctl enable --now cockpit.socket
sudo firewall-cmd --permanent --zone=public --add-service=cockpit
sudo firewall-cmd --reload

git clone --depth=1 https://github.com/Bash-it/bash-it.git .bash_it
cd .bash_it/
./install.sh --interactive

semanage port -a -t websm_port_t -p tcp 8080
semanage port -a -t websm_port_t -p tcp 80
semanage port -m -t websm_port_t -p tcp 443
semanage port -m -t websm_port_t -p tcp 9090

docker exec -it --user=1000 devshop drush @hostmaster vset devshop_public_key "$(docker exec -it --user=1000 devshop cat /var/aegir/.ssh/id_rsa.pub)" -y
