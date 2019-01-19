#!/usr/bin/env bash

source .env

export TDS_DOMAINNAME=$TDS_DOMAINNAME
export TDS_VOLUMEDIR=$TDS_VOLUMEDIR

## Get main ip
LOCAL_IPS=$(hostname -I)
LOCAL_IPAR=($LOCAL_IPS)
IP=${LOCAL_IPAR[0]}


touch ./install.log

echo "######  1.Preparing environment..."

echo "######  2.Creating persistent config storage in $TDS_VOLUMEDIR"
sudo mkdir --p $TDS_VOLUMEDIR/.config
sudo cp -r ./config/traefik $TDS_VOLUMEDIR/.config/


echo "######  3.Create and start proxy container -> traefik"
docker-compose -f ./services/traefik.docker-compose.yml up -d
ADDHOSTNAME="proxy.$TDS_DOMAINNAME proxy"
printf "%s\t%s\n" "$IP" "$ADDHOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

echo "######  Cleanup installation environment"
unset TDS_DOMAINNAME
unset TDS_VOLUMEDIR
echo "######  Finished"
