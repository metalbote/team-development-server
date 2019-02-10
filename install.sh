#!/usr/bin/env bash

echo "=================================================="
echo " Welcome to the Team Development Server Installer "
echo "                                                  "
echo "=================================================="

source .env

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
echo ""

if [ $OS = "opensuse-tumbleweed-kubic" ]; then
  echo "Running kubic setup...run following command in transactional-update shell"
  echo "cp -r ./cloud-init-config / && exit"
  exit
fi

# Install base packages
  echo "#### Install base packages..."
if [ $OS = "centos" ]; then
  yum install -y epel-release
  yum install mc curl net-tools wget yum-utils vim git samba-client samba-common cifs-utils httpd-tools
elif [  $OS = "ubuntu" ]; then
  sudo apt-get install mc curl net-tools wget yum-utils vim git samba-client samba-common cifs-utils httpd-tools
fi

# Install vm support packages
echo "#### Install vm support packages..."
if [ $OS = "centos" ]; then
  yum install -y open-vm-tools
elif [  $OS = "ubuntu" ]; then
  sudo apt-get install open-vm-tools
fi

if [ $OS = "centos" ]; then
# Install and prepare kernel environment
  echo "#### Install and prepare kernel environment..."
  yum group install "Development Tools"
  export kernel_headers=`ls -hd /usr/src/kernels/3*`
  sudo ln -s ${kernel_headers}/include/generated/uapi/linux/version.h ${kernel_headers}/include/linux/version.h
  sudo yum install "kernel-devel-uname-r == $(uname -r)"
fi

# Install and setup docker & docker-compose
  echo "#### Install and setup docker & docker-compose..."
if [ $OS = "centos" ]; then
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  yum update && yum upgrade
  yum install -y docker-ce
elif [  $OS = "ubuntu" ]; then
  sudo apt-get install apt-transport-https ca-certificates gnupg-agent software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io
fi
  sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
  sudo systemctl enable docker.service


# Install cockpit for browser based server management
  echo "#### Install cockpit for browser based server management..."
if [ $OS = "centos" ]; then
  sudo yum install -y cockpit cockpit-packagekit cockpit-storaged cockpit-system cockpit-docker
  sudo systemctl enable --now cockpit.socket
elif [  $OS = "ubuntu" ]; then
  sudo apt-get install -y cockpit cockpit-system cockpit-ws cockpit-dashboard cockpit-packagekit cockpit-storaged cockpit-docker
fi
  sudo systemctl enable --now cockpit.socket
  sudo firewall-cmd --permanent --zone=public --add-service=cockpit
  sudo firewall-cmd --reload

# Install bash-it framework for easier shell work (optional... but nice!)
  echo "#### Install bash-it framework for easier shell work (optional... but nice!)"
  git clone --depth=1 https://github.com/Bash-it/bash-it.git .bash_it
  cd .bash_it/
  start-containers.sh --silent
  bash-it enable alias vim systemd git docker-compose docker curl
  bash-it enable completion ssh git_flow git docker-compose docker
  bash-it enable plugin ssh less-pretty-cat git-subrepo git extract edit-mode-vi docker docker-compose

# Clone Team Development Server and setup containers
  echo "#### Clone Team Development Server and setup containers"
  sudo git clone https://github.com/metalbote/team-development-server.git /var/team-development-server

echo "#### Finished Installation"

echo "--------------------------------------------------"
echo " Please change to \"/var/team-development-server"\"
echo " and edit the \".env\" file to your needs.        "
echo "                                                  "
echo " Run \"sh start-containers.sh\" to spin up        "
echo "--------------------------------------------------"
echo ""
