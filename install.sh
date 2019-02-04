#!/usr/bin/env bash

echo "######  1.Preparing environment..."

## Load variables from .env file and set them explicit via export
## Remove export if error is solved
source .env

export TDS_BRANDING_LOGO_URL      = $TDS_BRANDING_LOGO_URL
export TDS_BRANDING_COMPANY_NAME  = $TDS_BRANDING_COMPANY_NAME
export TDS_BRANDING_INFO_EMAIL    = $TDS_BRANDING_INFO_EMAIL

export TDS_CONFIG_DIR             = $TDS_CONFIG_DIR
export TDS_VOLUMEDIR              = $TDS_VOLUMEDIR
export TDS_BACKUPDIR              = $TDS_BACKUPDIR
export TDS_DOMAINNAME             = $TDS_DOMAINNAME
export TDS_TIMEZONE               = $TDS_TIMEZONE

export TDS_MYSQL_ROOT_PASSWORD    = $TDS_MYSQL_ROOT_PASSWORD
export TDS_MYSQL_GITEAUSER        = $TDS_MYSQL_GITEAUSER
export TDS_MYSQL_GITEAPWD         = $TDS_MYSQL_GITEAPWD

export TDS_GIT_SSHPORT            = $TDS_GIT_SSHPORT
export TDS_GIT_USER_UID           = $TDS_GIT_USER_UID
export TDS_GIT_USER_GID           = $TDS_GIT_USER_GID
export TDS_GIT_REPO_DIR           = $TDS_GIT_REPO_DIR

export TDS_DEVSHOP_SSHPORT        = $TDS_DEVSHOP_SSHPORT

export TDS_DRONE_GITEA_SERVER     = $TDS_DRONE_GITEA_SERVER
export TDS_DRONE_SERVER_HOST      = $TDS_DRONE_SERVER_HOST
export TDS_DRONE_SERVER_PROTO     = $TDS_DRONE_SERVER_PROTO

## Get main ip
LOCAL_IPS=$(hostname -I)
LOCAL_IPAR=($LOCAL_IPS)
IP=${LOCAL_IPAR[0]}

echo "######  2.Creating persistent storage in $TDS_VOLUMEDIR and copy configuration"
## Shared config and backup folder
sudo mkdir --p $TDS_BACKUPDIR
sudo mkdir --p $TDS_VOLUMEDIR/.config/php
sudo mkdir --p $TDS_VOLUMEDIR/.config/mysql
sudo mkdir --p $TDS_VOLUMEDIR/.config/certs

# Portainer
if ${TDS_CREATE_CERTS}; then
  ./create-certs.sh
else
  echo "Skip certs generation"
fi

## traefik
sudo mkdir --p $TDS_VOLUMEDIR/traefik
sudo cp -r $TDS_CONFIG_DIR/traefik $TDS_VOLUMEDIR

## portainer
sudo mkdir --p $TDS_VOLUMEDIR/portainer
sudo cp -r $TDS_CONFIG_DIR/portainer $TDS_VOLUMEDIR

## mailhog
sudo mkdir --p $TDS_VOLUMEDIR/mailhog
sudo cp -r $TDS_CONFIG_DIR/mailhog $TDS_VOLUMEDIR
sudo echo "sendmail_path = /usr/sbin/sendmail -S mail:1025" > $TDS_VOLUMEDIR/.config/php/php-ext-mailhog.ini

## gitea
sudo mkdir --p $TDS_GIT_REPO_DIR
sudo mkdir --p $TDS_VOLUMEDIR/gitea
sudo cp -r $TDS_CONFIG_DIR/gitea $TDS_VOLUMEDIR
sudo chown -R TDS_GIT_USER_UID:TDS_GIT_USER_GID $TDS_GIT_REPO_DIR

## drone
sudo mkdir --p $TDS_VOLUMEDIR/drone
sudo cp -r $TDS_CONFIG_DIR/drone $TDS_VOLUMEDIR

## dashboard
sudo mkdir --p $TDS_VOLUMEDIR/dashboard
sudo cp -r $TDS_CONFIG_DIR/dashboard $TDS_VOLUMEDIR

## devshop
sudo mkdir --p $TDS_VOLUMEDIR/devshop
sudo cp -r $TDS_CONFIG_DIR/devshop $TDS_VOLUMEDIR

## custom mysql password not working
#sudo echo "[client]" > $TDS_VOLUMEDIR/devshop/data/.my.cnf
#sudo echo "user=root" >> $TDS_VOLUMEDIR/devshop/data/.my.cnf
#sudo echo "password=$TDS_MYSQL_ROOT_PASSWORD" >> $TDS_VOLUMEDIR/devshop/data/.my.cnf
#sudo echo "host=localhost" >> $TDS_VOLUMEDIR/devshop/mysql/.my.cnf
sudo chown -R 1000:1000 $TDS_CONFIG_DIR/devshop

echo "######  3.Add container names to /etc/hosts"
## traefik
ADDHOSTNAME="proxy.$TDS_DOMAINNAME proxy traefik.$TDS_DOMAINNAME traefik"
printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

## portainer
ADDHOSTNAME="portainer.$TDS_DOMAINNAME portainer"
printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

## mailhog
ADDHOSTNAME="mail.$TDS_DOMAINNAME mail mailhog.$TDS_DOMAINNAME mailhog"
printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

## gitea
ADDHOSTNAME="gitea.$TDS_DOMAINNAME git.$TDS_DOMAINNAME gitea git"
printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

## phpMyAdmin
ADDHOSTNAME="pma.$TDS_DOMAINNAME pma"
printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

## drone
ADDHOSTNAME="drone.$TDS_DOMAINNAME drone ci.$TDS_DOMAINNAME ci"
printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

## dashboard
ADDHOSTNAME="dashboard.$TDS_DOMAINNAME dashboard"
printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

## devshop
ADDHOSTNAME="devshop.$TDS_DOMAINNAME devshop"
printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;
echo "######  3.Create and start containers"
docker-compose up -d

echo "######  4.Setup ssh keys in devshop"
docker exec -it --user=1000 devshop ssh-keygen -q -t rsa -N "" -f /var/aegir/.ssh/id_rsa
docker exec -it --user=1000 devshop drush @hostmaster vset devshop_public_key "$(docker exec -it --user=1000 devshop cat /var/aegir/.ssh/id_rsa.pub)" -y --yes

echo "######  Cleanup installation environment"

unset $TDS_BRANDING_LOGO_URL
unset $TDS_BRANDING_COMPANY_NAME
unset $TDS_BRANDING_INFO_EMAIL

unset $TDS_CONFIG_DIR
unset $TDS_VOLUMEDIR
unset $TDS_BACKUPDIR
unset $TDS_DOMAINNAME
unset $TDS_TIMEZONE

unset $TDS_MYSQL_ROOT_PASSWORD
unset $TDS_MYSQL_GITEAUSER
unset $TDS_MYSQL_GITEAPWD

unset $TDS_GIT_SSHPORT
unset $TDS_GIT_USER_UID
unset $TDS_GIT_USER_GID
unset $TDS_GIT_REPO_DIR

unset $TDS_DEVSHOP_SSHPORT

unset $TDS_DRONE_GITEA_SERVER
unset $TDS_DRONE_SERVER_HOST
unset $TDS_DRONE_SERVER_PROTO

unset $LOCAL_IPS
unset $LOCAL_IPAR
unset $IP

echo "######  Finished"
