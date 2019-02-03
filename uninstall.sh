#!/usr/bin/env bash

echo "######  1.Preparing environment..."

## Load variables from .env file and set them explicit via export
source .env

export TDS_BRANDING_LOGO_URL=$TDS_BRANDING_LOGO_URL
export TDS_BRANDING_COMPANY_NAME=$TDS_BRANDING_COMPANY_NAME
export TDS_BRANDING_INFO_EMAIL=$TDS_BRANDING_INFO_EMAIL

export TDS_CONFIG_DIR=$TDS_CONFIG_DIR
export TDS_VOLUMEDIR=$TDS_VOLUMEDIR
export TDS_BACKUPDIR=$TDS_BACKUPDIR
export TDS_DOMAINNAME=$TDS_DOMAINNAME
export TDS_TIMEZONE=$TDS_TIMEZONE

export TDS_MYSQL_ROOT_PASSWORD=$TDS_MYSQL_ROOT_PASSWORD
export TDS_MYSQL_GITEAUSER=$TDS_MYSQL_GITEAUSER
export TDS_MYSQL_GITEAPWD=$TDS_MYSQL_GITEAPWD

export TDS_GIT_SSHPORT=$TDS_GIT_SSHPORT
export TDS_GIT_USER_UID=$TDS_GIT_USER_UID
export TDS_GIT_USER_GID=$TDS_GIT_USER_GID
export TDS_GIT_REPO_DIR=$TDS_GIT_REPO_DIR

export TDS_DEVSHOP_SSHPORT=$TDS_DEVSHOP_SSHPORT

## Get main ip
LOCAL_IPS=$(hostname -I)
LOCAL_IPAR=($LOCAL_IPS)
IP=${LOCAL_IPAR[0]}

echo "######  2.Stopping containers..."
docker container stop $(docker ps --filter="name=proxy" -q)
docker container stop $(docker ps --filter="name=portainer" -q)
docker container stop $(docker ps --filter="name=gitea" -q)
docker container stop $(docker ps --filter="name=giteadb" -q)
docker container stop $(docker ps --filter="name=mailhog" -q)
docker container stop $(docker ps --filter="name=pma" -q)
docker container stop $(docker ps --filter="name=devshop" -q)

echo "######  3.Create complete backup"
sudo mkdir --p ./backup
sudo tar czfP ./backup/$(date +%Y%m%d-%H%M%S)_persistent_folder.tar.gz $TDS_VOLUMEDIR/
sudo rm -r $TDS_VOLUMEDIR

echo "######  4.Cleanup containers, networks and volumes.."
docker system prune -f
docker network prune -f
docker volume rm $(docker volume ls -q) -f

echo "######  5.Remove containers from /etc/hosts..."

# Proxy and backup
REMHOSTNAME="proxy.$TDS_DOMAINNAME proxy"
sudo sed -i".bak" "/$REMHOSTNAME/d" /etc/hosts

# Portainer
REMHOSTNAME="portainer.$TDS_DOMAINNAME portainer"
sudo sed -i "/$REMHOSTNAME/d" /etc/hosts

# Gitea
REMHOSTNAME="gitea.$TDS_DOMAINNAME git.$TDS_DOMAINNAME gitea git"
sudo sed -i "/$REMHOSTNAME/d" /etc/hosts

# Mailhog
REMHOSTNAME="mail.$TDS_DOMAINNAME mail"
sudo sed -i "/$REMHOSTNAME/d" /etc/hosts

# phpMyAdmin
REMHOSTNAME="pma.$TDS_DOMAINNAME pma"
sudo sed -i "/$REMHOSTNAME/d" /etc/hosts

# devshop
REMHOSTNAME="devshop.$TDS_DOMAINNAME devshop"
sudo sed -i "/$REMHOSTNAME/d" /etc/hosts
echo "######  Finished"