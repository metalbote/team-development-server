#!/usr/bin/env bash

echo "######  1.Preparing environment..."

source .env

export TDS_BRANDING_LOGO_URL=$TDS_BRANDING_LOGO_URL
export TDS_BRANDING_COMPANY_NAME=$TDS_BRANDING_COMPANY_NAME

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

## Get main ip
LOCAL_IPS=$(hostname -I)
LOCAL_IPAR=($LOCAL_IPS)
IP=${LOCAL_IPAR[0]}
TODAY=$(date +%Y-%m-%d)

cd /

# Backup Gitea
mkdir --p $TDS_BACKUPDIR/gitea/data/
mkdir --p $TDS_BACKUPDIR/gitea/mysql/
mkdir --p $TDS_BACKUPDIR/gitea/repos/
## Gitea Data
rsync -avR --delete "$TDS_VOLUMEDIR/gitea/data"  "$TDS_BACKUPDIR/gitea/data/${TODAY}/" --link-dest="$TDS_BACKUPDIR/gitea/data/last/"
ln -nsf "$TDS_BACKUPDIR/gitea/data/${TODAY}/" --link-dest="$TDS_BACKUPDIR/gitea/data/last/"
## Gitea Mysql
docker exec giteadb /usr/bin/mysqldump --default-character-set=utf8mb4 -u root --password=$TDS_MYSQL_ROOT_PASSWORD | gzip > $TDS_BACKUPDIR/gitea/mysql/${TODAY}-giteadb.sql.gz
## Gitea Repo
rsync -avR --delete "$TDS_GIT_REPO_DIR"  "$TDS_BACKUPDIR/gitea/repos/${TODAY}/" --link-dest="$TDS_BACKUPDIR/gitea/repos/last/"
ln -nsf "$TDS_BACKUPDIR/gitea/repos/${TODAY}/" --link-dest="$TDS_BACKUPDIR/gitea/repos/last/"
