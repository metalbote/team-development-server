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

echo "######  3.Are all dockers reachable via http?"

# Proxy
if curl -s http://proxy.$TDS_DOMAINNAME | grep -q '<a href="/dashboard/">Found</a>'; then
  echo "Proxy is reachable!"
  STATUS=0
else
  echo "Proxy is NOT reachable!"
  STATUS=1
fi

# Portainer
if curl -s http://portainer.$TDS_DOMAINNAME | grep -q '<html lang="en" ng-app="portainer">'; then
  echo "Portainer is reachable!"
  STATUS=0
else
  echo "Portainer is NOT reachable!"
  STATUS=1
fi

# Gitea
if curl -s http://gitea.$TDS_DOMAINNAME | grep -q '<meta name="author" content="Gitea - Git with a cup of tea" />'; then
  echo "Gitea is reachable!"
  STATUS=0
else
  echo "Gitea is NOT reachable!"
  STATUS=1
fi

exit $STATUS
