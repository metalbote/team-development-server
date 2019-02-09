#!/usr/bin/env bash


echo "## 1/4 ## Load environment file aka config..."
source ../.env

echo "## 2/4 ## Create backup and repo directories if not exit..."
sudo mkdir --p $TDS_BACKUP_DIR
sudo mkdir --p $TDS_REPO_DIR
sudo chown -R $TDS_GITEA_USER_UID:TDS_GITEA_USER_GID $TDS_REPO_DIR

echo "## 3/4 ## Generate wildcard certificate..."
sudo bash ./create-certs.sh

echo "## 3/4 ## Create empty log files..."
touch ./../services/traefik/logs/access_traefik.log
touch ./../services/traefik/logs/traefik.log

echo "## 4/4 ## Spin up Containers ..."

docker-compose -f ./../docker-compose.yml  up -d

echo "## FINISH ! ##"
