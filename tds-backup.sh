#!/bin/bash
#
# Simple script for creating backups with Duplicity.
# Full backups are made on the 1st day of each month or with the 'full' option.
# Incremental backups are made on any other days.
#
# USAGE: backup.sh [full]
#

# get day of the month
DATE=`date +%d`
source /usr/local/share/team-development-server/.env

# directories to backup (use . for /)
CONTAINERS="tds-drone tds-gitea tds-mailhog tds-portainer"
BDIRS="var/lib/docker/volumes/team-development-server_tds-gitea-data/ var/lib/docker/volumes/team-development-server_tds-portainer-data/"
TDIR="var/backup/volumes"
DBDIR="var/backup/databases"
LOGDIR='/var/backup/log'
DB_CONTAINERS="tds_giteadb"
TIMESTAMP=$(date +"%F")


mkdir -p /$LOGDIR
mkdir -p /$TDIR

# Check to see if we're at the first of the month.
# If we are on the 1st day of the month, then run
# a full backup. If not, then run an incremental
# backup.

if [ $DATE = 01 ] || [ "$1" = 'full' ]; then
 TYPE='full'
else
 TYPE='incremental'
fi

for CONTAINER in $CONTAINERS
do
#  if [ $CONTAINER = "tds-gitea" ]; then
    #EXCLUDE="--exclude '/var/lib/docker/volumes/team-development-server_tds-gitea-data/_data/git/repositories'"
#  fi

  CMD="duplicity remove-older-than 2M -v5 --force file:///$TDIR/$CONTAINER >> $LOGDIR/$CONTAINER.log"
  eval $CMD

  # do a backup
  CMD="duplicity $TYPE -v5 --no-encryption $EXCLUDE /var/lib/docker/volumes/team-development-server_$CONTAINER-data/ file:///$TDIR/$CONTAINER >> $LOGDIR/$CONTAINER.log"
  eval  $CMD

done


for DB_CONTAINER in $DB_CONTAINERS
do
  mkdir -p /$DBDIR/$DB_CONTAINER/$TIMESTAMP

  databases=`docker exec $DB_CONTAINER sh -c 'exec mysql --user=root -p$TDS_MYSQL_ROOT_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"'`

  for db in $databases; do
    docker exec $DB_CONTAINER /usr/bin/mysqldump -u root --password=$TDS_MYSQL_ROOT_PASSWORD $db | gzip >  /$DBDIR/$DB_CONTAINER/$TIMESTAMP/$db.sql.gz
  done
  find /$DBDIR/$DB_CONTAINER -maxdepth 1 -type d -mtime +30 -exec rm -rf {} +
done
exit 0
