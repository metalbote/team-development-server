#!/usr/bin/env bash

echo "=================================================="
echo " Welcome to the Team Development Server Installer "
echo "                                                  "
echo "=================================================="

# Fail if not running as root (sudo)
if [ $EUID -ne 0 ]; then
    echo " This script must be run as root.  Try 'sudo -H bash install.sh'." 1>&2
    exit 1
fi

if [ -f '/etc/os-release' ]; then
    . /etc/os-release
    OS=$ID
    VERSION="$VERSION_ID"
    HOSTNAME_FQDN=`hostname --fqdn`

elif [ -f '/etc/lsb-release' ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VERSION="$DISTRIB_RELEASE"
    HOSTNAME_FQDN=`hostname --fqdn`

    if [ $OS == "Ubuntu" ]; then
      OS=ubuntu
    fi
elif [ -f '/etc/redhat-release' ]; then
    OS=$(cat /etc/redhat-release | awk '{print tolower($1);}')
    VERSION=$(cat /etc/redhat-release | awk '{print $3;}')
    HOSTNAME_FQDN=`hostname --fqdn`
fi

echo "--------------------------------------------------"
echo " Detected system environment:                     "
echo " OS: $OS                                          "
echo " Version: $VERSION                                "
echo " Hostname: $HOSTNAME_FQDN                         "
echo "--------------------------------------------------"


if [ $OS = "opensuse-tumbleweed-kubic" ]; then
  echo "Running kubic setup...run following command in transactional-update shell"
  echo "cp -r ./cloud-init-config / && exit"
  exit
fi
if [ $OS = "centos" ]; then
  echo "Running centos setup..."
  yum install epel-release
  yum install mc net-tools open-vm-tools wget yum-utils vim cockpit cockpit-packagekit cockpit-storaged cockpit-system git samba-client samba-common cifs-utils httpd-tools
  yum group install "Development Tools"
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum install docker-ce cockpit-docker
  export kernel_headers=`ls -hd /usr/src/kernels/3*`
  sudo ln -s ${kernel_headers}/include/generated/uapi/linux/version.h ${kernel_headers}/include/linux/version.h
  sudo yum install "kernel-devel-uname-r == $(uname -r)"
  yum update && yum upgrade

  sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

  sudo systemctl enable docker.service
  sudo systemctl enable --now cockpit.socket
  sudo firewall-cmd --permanent --zone=public --add-service=cockpit
  sudo firewall-cmd --reload

  git clone --depth=1 https://github.com/Bash-it/bash-it.git .bash_it
  cd .bash_it/
  ./install.sh --interactive

  semanage port -m -t websm_port_t -p tcp 8080
  semanage port -m -t websm_port_t -p tcp 80
  semanage port -m -t websm_port_t -p tcp 443
  semanage port -m -t websm_port_t -p tcp 9090
fi




#docker exec -it --user=1000 devshop drush @hostmaster vset devshop_public_key "$(docker exec -it --user=1000 devshop cat /var/aegir/.ssh/id_rsa.pub)" -y
