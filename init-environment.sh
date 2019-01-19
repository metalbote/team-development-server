#!/usr/bin/env bash

echo "######  1.Preparing environment..."

source .env

export TDS_BRANDING_LOGO_URL=$TDS_BRANDING_LOGO_URL
export TDS_BRANDING_COMPANY_NAME=$TDS_BRANDING_COMPANY_NAME

export TDS_CONFIG_DIR=$TDS_CONFIG_DIR
export TDS_VOLUMEDIR=$TDS_VOLUMEDIR
export TDS_DOMAINNAME=$TDS_DOMAINNAME
export TDS_TIMEZONE=$TDS_TIMEZONE

export TDS_MYSQL_ROOT_PASSWORD=$TDS_MYSQL_ROOT_PASSWORD
export TDS_MYSQL_GITEAUSER=$TDS_MYSQL_GITEAUSER
export TDS_MYSQL_GITEAPWD=$TDS_MYSQL_GITEAPWD

export TDS_GIT_SSHPORT=$TDS_GIT_SSHPORT
export TDS_GIT_USER_UID=$TDS_GIT_USER_UID
export TDS_GIT_USER_GID=$TDS_GIT_USER_GID
export TDS_GIT_REPO_DIR=$TDS_GIT_REPO_DIR

## Get main ip
LOCAL_IPS=$(hostname -I)
LOCAL_IPAR=($LOCAL_IPS)
IP=${LOCAL_IPAR[0]}

echo "######  2.Creating persistent config storage in $TDS_VOLUMEDIR"
sudo mkdir --p $TDS_VOLUMEDIR/.config
sudo mkdir --p $TDS_VOLUMEDIR/.mails
sudo mkdir --p $TDS_GIT_REPO_DIR
sudo cp -r $TDS_CONFIG_DIR $TDS_VOLUMEDIR/.config/

echo "######  3.Create and start proxy container -> traefik"
docker-compose -f ./services/traefik.docker-compose.yml up -d
ADDHOSTNAME="proxy.$TDS_DOMAINNAME proxy"
printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

echo "######  4.Create and start dockermanagement container -> portainer"
docker-compose -f ./services/portainer.docker-compose.yml up -d
ADDHOSTNAME="portainer.$TDS_DOMAINNAME portainer"
printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

echo "######  5.Create and start git container -> gitea"
docker-compose -f ./services/gitea.docker-compose.yml up -d
ADDHOSTNAME="gitea.$TDS_DOMAINNAME git.$TDS_DOMAINNAME gitea git"
printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

echo "######  5.Create and start mailcatcher container -> mailhog"
docker-compose -f ./services/mailhog.docker-compose.yml up -d
ADDHOSTNAME="mail.$TDS_DOMAINNAME mail"
printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;


echo "######  Cleanup installation environment"

unset TDS_BRANDING_COMPANY_NAME
unset TDS_BRANDING_LOGO_URL

unset TDS_CONFIG_DIR
unset TDS_VOLUMEDIR
unset TDS_DOMAINNAME
unset TDS_TIMEZONE

unset TDS_MYSQL_ROOT_PASSWORD
unset TDS_MYSQL_GITEAUSER
unset TDS_MYSQL_GITEAPWD

unset TDS_GIT_SSHPORT
unset TDS_GIT_USER_UID
unset TDS_GIT_USER_GID
unset TDS_GIT_REPO_DIR

echo "######  Finished"
