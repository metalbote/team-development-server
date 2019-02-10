#!/bin/bash
echo "Starting ... " &> ./setup.log

echo -e "\e[32m#### Load environment file aka config...\e[0m" 2>&1 | tee ./setup.log
source /var/team-development-server/.env >> ./install.log
sudo systemctl start docker >> ./install.log

echo -e "\e[32m#### Create backup and repo directories if not exit...\e[0m" 2>&1 | tee ./setup.log
sudo mkdir --p $TDS_BACKUP_DIR >> ./install.log
sudo mkdir --p $TDS_REPO_DIR >> ./install.log
sudo chown -R $TDS_GITEA_USER_UID:$TDS_GITEA_USER_GID $TDS_REPO_DIR >> ./install.log

echo -e "\e[32m#### Generate wildcard certificate...\e[0m" 2>&1 | tee ./setup.log
sudo bash /var/team-development-server/create-certs.sh

echo -e "\e[32m#### Create empty log files...\e[0m" 2>&1 | tee ./setup.log
sudo mkdir --p /var/team-development-server/services/traefik/logs >> ./install.log
sudo touch /var/team-development-server/services/traefik/logs/access_traefik.log >> ./install.log
sudo touch /var/team-development-server/services/traefik/logs/traefik.log >> ./install.log

echo -e "\e[32m#### Spin up Containers...\e[0m" 2>&1 | tee ./setup.log

sudo docker-compose -f /var/team-development-server/docker-compose.yml up -d

echo -e "\e[32m#### FINISH ! ##\e[0m" 2>&1 | tee ./setup.log
