#!/usr/bin/env bash

source ./config/services.env

export TDS_DOMAINNAME=$TDS_DOMAINNAME
export TDS_VOLUMEDIR=$TDS_VOLUMEDIR


touch ./install.log

echo "######  1.Preparing environment..."

echo "######  2.Creating persistent config storage in $TDS_VOLUMEDIR"
sudo mkdir --p $TDS_VOLUMEDIR/.config
sudo cp -r ./config/traefik $TDS_VOLUMEDIR/.config/


echo "######  3.Create and start proxy container -> traefik"
docker-compose -f ./services/traefik.docker-compose.yml up -d


echo "######  Cleanup installation environment"
unset TDS_DOMAINNAME
unset TDS_VOLUMEDIR
echo "######  Finished"