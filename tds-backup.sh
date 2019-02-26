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


# directories to backup (use . for /)
CONTAINERS="tds-drone tds-gitea tds-mailhog tds-portainer"
BDIRS="var/lib/docker/volumes/team-development-server_tds-gitea-data/ var/lib/docker/volumes/team-development-server_tds-portainer-data/"
TDIR="var/backup/volumes"
LOGDIR='/var/backup/log'


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
exit 0
