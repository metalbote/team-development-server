#!/bin/bash

usage(){
echo "USAGE:
    `basename $0` [options]
  Options:
    -t, --time TIME            specify the time from which to restore or list files
"
}
while getopts ":c:t:bfvlsnd-:" opt; do
  case $opt in
    c) CONFIG=$OPTARG;; # set the config file from the command line
    t) TIME=$OPTARG;; # set the restore time from the command line
    :)
      echo "Option -$OPTARG requires an argument." >&2
      COMMAND=""
    ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      COMMAND=""
    ;;
  esac
done

# directories to backup (use . for /)
CONTAINERS="tds-drone tds-gitea tds-mailhog tds-portainer"
BDIRS="var/backup/volumes"
TDIR="var/backup/restore"
LOGDIR='/var/backup/log'

mkdir -p /$TDIR


for CONTAINER in $CONTAINERS
do
  if [ ! -z "$TIME" ]; then
      STATIC_OPTIONS="--time $TIME"
      rm -rf /$TDIR/restore/$TIME/$CONTAINER
      CMD="duplicity restore $STATIC_OPTIONS --no-encryption file:///$BDIRS/$CONTAINER /$TDIR/$TIME/$CONTAINER"
  else
    rm -rf /$TDIR/restore/last/$CONTAINER
    CMD="duplicity restore --no-encryption file:///$BDIRS/$CONTAINER /$TDIR/last/$CONTAINER"
  fi
  eval  $CMD
done

exit 0
