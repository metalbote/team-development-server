#!/bin/bash

echo -e "\e[32m#####  Creating certs for traefik service\e[0m"
source /var/team-development-server/.env

TDS_CERTDIR="/var/team-development-server/services/traefik/certs"
sudo mkdir --p $TDS_BACKUP_DIR

sudo openssl genrsa -out "/var/team-development-server/services/traefik/certs/wildcard.key" 2048
sudo openssl req -new -subj "/C=${TDS_CERT_COUNTRY}/ST=${TDS_CERT_STATE}/O=${TDS_CERT_COMPANY_NAME}/localityName=${TDS_CERT_CITY}/commonName=${TDS_CERT_DOMAIN}/organizationalUnitName=${TDS_CERT_DOMAIN}/emailAddress=${TDS_CERT_EMAIL}" -key "${TDS_CERTDIR}/wildcard.key" -out "${TDS_CERTDIR}/wildcard.csr"
sudo openssl x509 -req -days 365 -in "${TDS_CERTDIR}/wildcard.csr" -signkey "${TDS_CERTDIR}/wildcard.key" -out "${TDS_CERTDIR}/wildcard.crt"

# Converting
sudo openssl pkcs12 -export -name "${TDS_CERTDIR}/wildcard" -out ${TDS_CERTDIR}/wildcard.pfx -inkey ${TDS_CERTDIR}/wildcard.key -in ${TDS_CERTDIR}/wildcard.crt -password pass:${TDS_CERT_PASSWORD}
sudo openssl x509 -inform PEM -in ${TDS_CERTDIR}/wildcard.crt -outform DER -out ${TDS_CERTDIR}/wildcard.der

echo -e "\e[32m####  Finished\e[0m"
