#!/usr/bin/env bash

source ./config/services.env

echo "######  1.Stopping containers..."
docker container stop $(docker container ls -a -q)

echo "######  2.Create backup of persistent folder..."
mkdir --p ./backup
tar czfP ./backup/$(date +%Y%m%d-%H%M%S)_persistent_folder.tar.gz $TDS_VOLUMEDIR/
rm -r $TDS_VOLUMEDIR


echo "######  3.Cleanup containers, networks and volumes.."
docker system prune -f
docker network prune -f
docker volume rm $(docker volume ls -q) -f

echo "######  Finished"

echo $TDS_VOLUMEDIR
