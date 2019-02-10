#!/bin/bash

echo -e "\e[32m==================================================\e[0m" &> ./install.log
echo -e "\e[32m Welcome to the Team Development Server Installer \e[0m" &>> ./install.log
echo -e "\e[32m                                                  \e[0m" &>> ./install.log
echo -e "\e[32m==================================================\e[0m" &>> ./install.log



# Fail if not running as root (sudo)
if [ $EUID -ne 0 ]; then
    echo -e "\e[32m This script must be run as root.  Try 'sudo -H bash install.sh'.\e[0m" 1>&2
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

echo -e "\e[32m--------------------------------------------------\e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m Detected system environment:                     \e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m OS: $OS                                          \e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m Version: $VERSION                                \e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m Hostname: $HOSTNAME_FQDN                         \e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m--------------------------------------------------\e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m\e[0m" 2>&1 | tee ./install.log

if [ $OS = "opensuse-tumbleweed-kubic" ]; then
  echo -e "\e[32mRunning kubic setup...run following command in transactional-update shell\e[0m" 2>&1 | tee ./install.log
  echo -e "\e[32mcp -r ./cloud-init-config / && exit\e[0m" 2>&1 | tee ./install.log
  exit
fi

# Install base packages
  echo -e "\e[32m#### Install base packages...\e[0m" 2>&1 | tee ./install.log
if [ $OS = "centos" ]; then
  yum install -y epel-release >> ./install.log
  yum install -y mc curl net-tools wget yum-utils vim git samba-client samba-common cifs-utils httpd-tools >> ./install.log
elif [  $OS = "ubuntu" ]; then
  sudo apt-get install -y mc curl net-tools wget vim git smbclient cifs-utils samba-common apache2-utils >> ./install.log
fi

# Install vm support packages
echo -e "\e[32m#### Install vm support packages...\e[0m" 2>&1 | tee ./install.log
if [ $OS = "centos" ]; then
  yum install -y open-vm-tools >> ./install.log
elif [  $OS = "ubuntu" ]; then
  sudo apt-get install -y open-vm-tools >> ./install.log
fi

if [ $OS = "centos" ]; then
# Install and prepare kernel environment
  echo -e "\e[32m#### Install and prepare kernel environment...\e[0m" 2>&1 | tee ./install.log
  yum group install -y "Development Tools" >> ./install.log
  export kernel_headers=`ls -hd /usr/src/kernels/3*`
  sudo ln -s ${kernel_headers}/include/generated/uapi/linux/version.h ${kernel_headers}/include/linux/version.h >> ./install.log
  sudo yum install -y "kernel-devel-uname-r == $(uname -r)" >> ./install.log
fi

# Install and setup docker & docker-compose
  echo -e "\e[32m#### Install and setup docker & docker-compose...\e[0m" 2>&1 | tee ./install.log
if [ $OS = "centos" ]; then
  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo >> ./install.log
  yum update >> ./install.log
  yum upgrade >> ./install.log
  yum install -y docker-ce >> ./install.log
elif [  $OS = "ubuntu" ]; then
  sudo apt-get install -y apt-transport-https ca-certificates gnupg-agent software-properties-common >> ./install.log
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" >> ./install.log
  sudo apt-get update -y >> ./install.log
  sudo apt-get upgrade -y >> ./install.log
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io >> ./install.log
fi
  sudo curl -s -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >> ./install.log
  sudo chmod +x /usr/local/bin/docker-compose &>> ./install.log
  sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose &>> ./install.log
  sudo systemctl enable docker.service &>> ./install.log
  sudo systemctl start docker.service &>> ./install.log


# Install cockpit for browser based server management
  echo -e "\e[32m#### Install cockpit for browser based server management...\e[0m" 2>&1 | tee ./install.log
if [ $OS = "centos" ]; then
  sudo yum install -y cockpit cockpit-packagekit cockpit-storaged cockpit-system cockpit-docker >> ./install.log
  sudo systemctl enable --now cockpit.socket >> ./install.log
  sudo firewall-cmd --permanent --zone=public --add-service=cockpit >> ./install.log
  sudo firewall-cmd --reload >> ./install.log
elif [  $OS = "ubuntu" ]; then
  sudo apt-get install -y cockpit cockpit-system cockpit-ws cockpit-dashboard cockpit-packagekit cockpit-storaged cockpit-docker >> ./install.log
fi


# Install bash-it framework for easier shell work (optional... but nice!)
if [ $OS = "centos" ]; then
  echo -e "\e[32m#### Install bash-it framework for easier shell work (optional... but nice!)\e[0m" 2>&1 | tee ./install.log
  git clone --depth=1 -q https://github.com/Bash-it/bash-it.git .bash_it >> ./install.log
  cd .bash_it/
  bash ./install.sh --silent >> ../install.log
  source /root/.bashrc
  bash-it enable alias vim systemd git docker-compose docker curl >> ../install.log
  bash-it enable completion ssh git_flow git docker-compose docker >> ../install.log
  bash-it enable plugin ssh less-pretty-cat git-subrepo git extract edit-mode-vi docker docker-compose >> ../install.log
fi

# Clone Team Development Server and setup containers
  echo -e "\e[32m#### Clone Team Development Server and setup containers\e[0m" 2>&1 | tee ./install.log
  sudo git clone --depth=1 -q https://github.com/metalbote/team-development-server.git /var/team-development-server >> ../install.log

echo -e "\e[32m#### Finished Installation\e[0m" 2>&1 | tee ./install.log

echo -e "\e[32m--------------------------------------------------\e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m Please change to \"/var/team-development-server\"\e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m and edit the \".env\" file to your needs.        \e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m                                                  \e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m Run \"sudo bash start-containers.sh\" to spin up      \e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m--------------------------------------------------\e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m\e[0m" 2>&1 | tee ./install.log
