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

# Install base packages
  echo -e "\e[32m#### Install base packages...\e[0m" 2>&1 | tee ./install.log
if [ $OS = "centos" ]; then
  sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY*

# Install and prepare kernel environment
  echo -e "\e[32m#### Install and prepare kernel environment...\e[0m" 2>&1 | tee ./install.log
  sudo yum -y groupinstall 'Development Tools' >> ./install.log
  export kernel_headers=`ls -hd /usr/src/kernels/3*`
  sudo ln -s ${kernel_headers}/include/generated/uapi/linux/version.h ${kernel_headers}/include/linux/version.h >> ./install.log
  sudo yum install -y "kernel-devel-uname-r == $(uname -r)" >> ./install.log

  sudo yum install -y epel-release >> ./install.log
  sudo yum update -y >> ./install.log
  sudo yum upgrade -y >> ./install.log
  sudo yum install -y setroubleshoot-server sos mc curl net-tools wget yum-utils vim git samba-client samba-common cifs-utils httpd-tools duplicity >> ./install.log
elif [  $OS = "ubuntu" ]; then
  sudo apt-get install -y mc openssh-server curl net-tools wget vim git smbclient cifs-utils samba-common apache2-utils >> ./install.log
fi

# Setup ssh port to 1022
#echo -e "\e[32m#### Setup ssh port to 1022...\e[0m" 2>&1 | tee ./install.log
#sudo echo "port 1022" >> /etc/ssh/sshd_config
#sudo echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
#sudo firewall-cmd --permanent --zone=public --add-port=1022/tcp
# sudo semanage port -a -t ssh_port_t -p tcp 2292
#systemctl restart sshd

# Setup samba
#echo -e "\e[32m#### Setup samba...\e[0m" 2>&1 | tee ./install.log
#sudo echo "username=${TDS_SAMBA_USER}" > /root/.samba.cred
#sudo echo "password=${TDS_SAMBA_PASSWD}" >> /root/.samba.cred
#sudo echo "domain=${TDS_SAMBA_DOMAIN}" >> /root/.samba.cred
#sudo echo "//${TDS_SAMBA_SERVER}/${TDS_SAMBA_SHARE}  ${TDS_SAMBA_MOUNT} cifs    user,uid=1000,gid=1000,rw,nounix,iocharset=utf8,suid,credentials=/root/.samba.cred 0 0" >> /etc/fstab

# Setup Mysql conf
#echo -e "\e[32m#### Setup mysql.conf...\e[0m" 2>&1 | tee ./install.log
#sudo echo "[client]" > /root/.my.cnf
#sudo echo 'user="root"' >> /root/.my.cnf
#sudo echo "password=${TDS_MYSQL_ROOT_PASSWORD}" >> /root/.my.cnf

# Install vm support packages
echo -e "\e[32m#### Install vm support packages...\e[0m" 2>&1 | tee ./install.log
if [ $OS = "centos" ]; then
  sudo yum install -y open-vm-tools >> ./install.log
elif [  $OS = "ubuntu" ]; then
  sudo apt-get install -y open-vm-tools >> ./install.log
fi

# Install and setup docker & docker-compose
  echo -e "\e[32m#### Install and setup docker & docker-compose...\e[0m" 2>&1 | tee ./install.log
if [ $OS = "centos" ]; then
  yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo >> ./install.log
  yum update -y >> ./install.log
  yum upgrade -y >> ./install.log
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
  sudo yum install -y cockpit cockpit-composer cockpit-dashboard cockpit-doc cockpit-docker cockpit-packagekit cockpit-storaged cockpit-system cockpit-ws>> ./install.log
  sudo systemctl enable --now cockpit.socket >> ./install.log
  sudo firewall-cmd --permanent --zone=public --add-service=cockpit >> ./install.log
  sudo firewall-cmd --permanent --zone=public --add-service=http
  sudo firewall-cmd --permanent --zone=public --add-service=https
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
  bash-it enable alias composer curl docker docker-compose general git systemd vim >> ../install.log
  bash-it enable completion bash-it composer defaults dirs docker docker-compose drush export git git_flow packer ssh system >> ../install.log
  bash-it enable plugin autojump base docker docker-compose edit-mode-vi extract git git-subrepo history less-pretty-cat ssh >> ../install.log
fi


# Setup correct hostnames for services
  echo -e "\e[32m#### Setup correct hostnames for services\e[0m" 2>&1 | tee ./install.log
if [ $OS = "centos" ]; then
  sudo yum install dnsmasq bind-utils -y

  ## Get main ip
  LOCAL_IPS=$(hostname -I)
  LOCAL_IPAR=($LOCAL_IPS)
  IP=${LOCAL_IPAR[0]}

  touch /etc/dnsmasq.hosts

  ## traefik
  ADDHOSTNAME="proxy.$TDS_DOMAINNAME proxy tds_proxy"
  printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/dnsmasq.hosts > /dev/null;
  printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

  ## portainer
  ADDHOSTNAME="portainer.$TDS_DOMAINNAME portainer tds_portainer"
  printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/dnsmasq.hosts > /dev/null;
  printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

  ## mailhog
  ADDHOSTNAME="mail.$TDS_DOMAINNAME mail mailhog.$TDS_DOMAINNAME mailhog tds_mailhog"
  printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/dnsmasq.hosts > /dev/null;
  printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

  ## phpMyAdmin
  ADDHOSTNAME="pma.$TDS_DOMAINNAME pma tds_pma"
  printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/dnsmasq.hosts > /dev/null;
  printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

  ## gitea
  ADDHOSTNAME="gitea.$TDS_DOMAINNAME gitea tds_gitea"
  printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/dnsmasq.hosts > /dev/null;
  printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

  ## drone
  ADDHOSTNAME="drone.$TDS_DOMAINNAME drone tds_drone"
  printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/dnsmasq.hosts > /dev/null;
  printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

  systemctl stop dnsmasq
  systemctl stop docker

  TDS_DOCKER_DNS="/usr/bin/dockerd -H fd:// --dns 192.168.0.99 --dns 8.8.8.8 --dns 8.8.4.4"
  sed -i "s|ExecStart=.*|ExecStart=--selinux-enabled ${TDS_DOCKER_DNS}|g" /usr/lib/systemd/system/docker.service;

  systemctl daemon-reload
  systemctl enable dnsmasq
  systemctl start docker
fi

# Clone Team Development Server and setup containers
  echo -e "\e[32m#### Clone Team Development Server and setup containers\e[0m" 2>&1 | tee ./install.log
  sudo git clone --depth=1 -q https://github.com/metalbote/team-development-server.git /usr/local/share/team-development-server >> ../install.log


echo -e "\e[32m#### Finished Installation\e[0m" 2>&1 | tee ./install.log

echo -e "\e[32m--------------------------------------------------\e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m Please change to \"/var/team-development-server\"\e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m and edit the \".env\" file to your needs.        \e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m                                                  \e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m Run \"sudo bash start-containers.sh\" to spin up      \e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m--------------------------------------------------\e[0m" 2>&1 | tee ./install.log
echo -e "\e[32m\e[0m" 2>&1 | tee ./install.log

cd /usr/local/share/team-development-server
