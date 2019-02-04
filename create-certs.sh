#!/bin/sh

source .env


## Get main ip
LOCAL_IPS=$(hostname -I)
LOCAL_IPAR=($LOCAL_IPS)
IP=${LOCAL_IPAR[0]}

certdir="${TDS_VOLUMEDIR}/.config/certs"
host="$HOSTNAME.${TDS_DOMAINNAME}"
wildcardhost="*.${TDS_DOMAINNAME}"
subj="/C=${TDS_BRANDING_COMPANY_COUNTRY}/ST=${TDS_BRANDING_COMPANY_STATE}/L=${TDS_BRANDING_COMPANY_CITY}/O=${TDS_BRANDING_COMPANY_NAME}/OU=${TDS_BRANDING_COMPANY_DEPARTMENT}/CN=${wildcardhost}"
subjAlt= "${IP}, IP:127.0.0.1,DNS: ${host}, DNS: proxy.${TDS_DOMAINNAME}, DNS: traefik.${TDS_DOMAINNAME}, DNS: portainer.${TDS_DOMAINNAME}, DNS: mail.${TDS_DOMAINNAME}, DNS: mailhog.${TDS_DOMAINNAME}, DNS: gitea.${TDS_DOMAINNAME}, DNS: pma.${TDS_DOMAINNAME}, DNS: drone.${TDS_DOMAINNAME}, DNS: ci.${TDS_DOMAINNAME}, DNS: dashboard.${TDS_DOMAINNAME}, DNS: devshop.${TDS_DOMAINNAME}, DNS: localhost, DNS: *.devhop.entwicklung"


# setup a CA key
if [ ! -f "$certdir/ca-key.pem" ]; then
  openssl genrsa -out "${certdir}/ca-key.pem" 4096
fi

# setup a CA cert
openssl req -new -x509 -days 365 -subj ${subj} -key "${certdir}/ca-key.pem" -sha256 -out "${certdir}/ca.pem"

# setup a host key
if [ ! -f "${certdir}/key.pem" ]; then
  openssl genrsa -out "${certdir}/key.pem" 2048
fi

# create a signing request
extfile="${certdir}/extfile"
openssl req -subj "${subj}" -new -key "${certdir}/key.pem" -out "${certdir}/${host}.csr"
echo "subjectAltName = ${subjAlt}" > ${extfile}

# create the host cert
openssl x509 -req -days 365 -in "${certdir}/${host}.csr" -extfile "${certdir}/extfile" -CA "${certdir}/ca.pem" -CAkey "${certdir}/ca-key.pem" -CAcreateserial -out "${certdir}/cert.pem"

openssl req -x509 -subj "${subj}" -nodes -days 365 -key "${certdir}/key.pem" -keyout ${certdir}/wildcard.key -out ${certdir}/wildcard.crt
openssl req -x509 -subj "${subj}" -nodes -days 365 -sha256 -key -key "${certdir}/key.pem" -out ${certdir}/wildcard.cert

# cleanup
if [ -f "${certdir}/${host}.csr" ]; then
        rm -f -- "${certdir}/${host}.csr"
fi
if [ -f "${extfile}" ]; then
        rm -f -- "${extfile}"
fi
