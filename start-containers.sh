#!/bin/bash
echo "Starting ... " &> ./setup.log

echo -e "\e[32m#### Load environment file aka config...\e[0m" 2>&1 | tee ./setup.log
source /var/team-development-server/.env >> ./setup.log
sudo systemctl start docker>> ./setup.log

echo -e "\e[32m#### Create backup and repo directories if not exit...\e[0m" 2>&1 | tee ./setup.log
sudo mkdir --p $TDS_BACKUP_DIR >> ./setup.log
sudo mkdir --p $TDS_REPO_DIR >> ./setup.log
sudo chown -R $TDS_GITEA_USER_UID:$TDS_GITEA_USER_GID $TDS_REPO_DIR >> ./setup.log

echo -e "\e[32m#### Generate wildcard certificate...\e[0m" 2>&1 | tee ./setup.log
sudo mkdir --p /var/team-development-server/services/traefik/certs
sudo openssl genrsa -out "/var/team-development-server/services/traefik/certs/wildcard.key" 2048 >> ./setup.log
sudo openssl req -new -subj "/C=${TDS_CERT_COUNTRY}/ST=${TDS_CERT_STATE}/O=${TDS_CERT_COMPANY_NAME}/localityName=${TDS_CERT_CITY}/commonName=${TDS_CERT_DOMAIN}/organizationalUnitName=${TDS_CERT_DOMAIN}/emailAddress=${TDS_CERT_EMAIL}" -key "/var/team-development-server/services/traefik/certs/wildcard.key" -out "/var/team-development-server/services/traefik/certs/wildcard.csr" >> ./setup.log
sudo openssl x509 -req -days 365 -in "/var/team-development-server/services/traefik/certs/wildcard.csr" -signkey "/var/team-development-server/services/traefik/certs/wildcard.key" -out "/var/team-development-server/services/traefik/certs/wildcard.crt" >> ./setup.log

# Converting
sudo openssl pkcs12 -export -name "/var/team-development-server/services/traefik/certs/wildcard" -out /var/team-development-server/services/traefik/certs/wildcard.pfx -inkey /var/team-development-server/services/traefik/certs/wildcard.key -in /var/team-development-server/services/traefik/certs/wildcard.crt -password pass:${TDS_CERT_PASSWORD} >> ./setup.log
sudo openssl x509 -inform PEM -in /var/team-development-server/services/traefik/certs/wildcard.crt -outform DER -out /var/team-development-server/services/traefik/certs/wildcard.der >> ./setup.log

echo -e "\e[32m#### Create empty log files...\e[0m" 2>&1 | tee ./setup.log
sudo mkdir --p /var/team-development-server/services/traefik/logs >> ./setup.log
sudo touch /var/team-development-server/services/traefik/logs/access_traefik.log >> ./setup.log
sudo touch /var/team-development-server/services/traefik/logs/traefik.log >> ./setup.log

echo -e "\e[32m#### Spin up Containers...\e[0m" 2>&1 | tee ./setup.log

sudo docker-compose -f /var/team-development-server/docker-compose.yml up -d

echo -e "\e[32m#### FINISH ! ##\e[0m" 2>&1 | tee ./setup.log
