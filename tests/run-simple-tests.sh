#!/usr/bin/env bash

echo "######  1.Preparing environment..."

sleep 1m
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

## Get main ip
LOCAL_IPS=$(hostname -I)
LOCAL_IPAR=($LOCAL_IPS)
IP=${LOCAL_IPAR[0]}
STATUS=0
echo "######  2.Are all dockers running?"

# Proxy
if docker ps --filter="name=proxy" -q; then
  echo "Proxy is running!"
  STATUS=0
else
  echo "Proxy is NOT running."
  STATUS=1
fi

# Portainer
if docker ps --filter="name=portainer" -q; then
  echo "Portainer is running!"
  STATUS=0
else
  echo "Portainer is NOT running."
  STATUS=1
fi

# Gitea
if docker ps --filter="name=gitea" -q; then
  echo "Gitea is running!"
  STATUS=0
else
  echo "Gitea is NOT running."
  STATUS=1
fi

# mailhog
if docker ps --filter="name=mailhog" -q; then
  echo "Mailhog is running!"
  STATUS=0
else
  echo "Mailhog is NOT running."
  STATUS=1
fi

# phpMyAdmin
if docker ps --filter="name=pma" -q; then
  echo "phpMyAdmin is running!"
  STATUS=0
else
  echo "phpMyAdmin is NOT running."
  STATUS=1
fi

# devshop
if docker ps --filter="name=devshop" -q; then
  echo "devshop is running!"
  STATUS=0
else
  echo "devshop is NOT running."
  STATUS=1
fi
echo "######  3.Are all dockers reachable via http?"

# Proxy
if curl -s http://proxy.$TDS_DOMAINNAME | cat |  grep -q '<a href="/dashboard/">Found</a>'; then
  echo "Proxy is reachable!"
  STATUS=0
else
  echo "Proxy is NOT reachable!"
  STATUS=1
fi

# Portainer
if curl -s http://portainer.$TDS_DOMAINNAME | cat |  grep -q '<html lang="en" ng-app="portainer">'; then
  echo "Portainer is reachable!"
  STATUS=0
else
  echo "Portainer is NOT reachable!"
  STATUS=1
fi

# Gitea
GITEA_INSTALL= curl -s http://gitea.$TDS_DOMAINNAME | cat | grep -q '<meta name="author" content="Gitea - Git with a cup of tea" />';
GITEA_RUN= curl -s http://gitea.$TDS_DOMAINNAME | cat | grep -q '<a href="/explore">Found</a>';

if $GITEA_RUN || $GITEA_INSTALL; then
  echo "Gitea is reachable!"
  STATUS=0
else
  echo "Gitea is NOT reachable!"
  STATUS=1
fi

# Mailhog
if curl -s http://mail.$TDS_DOMAINNAME | cat |  grep -q '<img src="images/hog.png" height="20" alt="MailHog">'; then
  echo "Mailhog is reachable!"
  STATUS=0
else
  echo "Mailhog is NOT reachable!"
  STATUS=1
fi

# phpMyAdmin
if curl -s http://pma.$TDS_DOMAINNAME | cat |  grep -q '<a href="./url.php?url=https%3A%2F%2Fwww.phpmyadmin.net%2F" target="_blank" rel="noopener noreferrer" class="logo">'; then
  echo "phpMyAdmin is reachable!"
  STATUS=0
else
  echo "phpMyAdmin is NOT reachable!"
  STATUS=1
fi

# devshop
if curl -s http://devshop.$TDS_DOMAINNAME/user/login | cat |  grep -q '<title>Login | devshop'; then
  echo "devshop is reachable!"
  STATUS=0
else
  echo "devshop is NOT reachable!"
  STATUS=1
fi

exit $STATUS
