#!/usr/bin/env bash

echo "######  1.Preparing environment..."

source .env

export TDS_DOMAINNAME=$TDS_DOMAINNAME
export TDS_VOLUMEDIR=$TDS_VOLUMEDIR

## Get main ip
LOCAL_IPS=$(hostname -I)
LOCAL_IPAR=($LOCAL_IPS)
IP=${LOCAL_IPAR[0]}

echo "######  2.Stopping containers..."
docker container stop $(docker container ls -a -q)

echo "######  3.Create backup of persistent folder..."
sudo mkdir --p ./backup
sudo tar czfP ./backup/$(date +%Y%m%d-%H%M%S)_persistent_folder.tar.gz $TDS_VOLUMEDIR/
sudo rm -r $TDS_VOLUMEDIR

echo "######  4.Cleanup containers, networks and volumes.."
docker system prune -f
docker network prune -f
docker volume rm $(docker volume ls -q) -f

echo "######  5.Remove containers from /etc/hosts..."
REMHOSTNAME="proxy.$TDS_DOMAINNAME proxy"
sudo sed -i".bak" "/$REMHOSTNAME/d" /etc/hosts
REMHOSTNAME="portainer.$TDS_DOMAINNAME portainer"
sudo sed -i "/$REMHOSTNAME/d" /etc/hosts

echo "######  Finished"

