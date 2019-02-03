#!/bin/sh

certdir="/var/tds-storage/traefik/certs"
host="server.entwicklung"
wildcardhost="*.entwicklung"

# setup a CA key
if [ ! -f "$certdir/ca-key.pem" ]; then
  openssl genrsa -out "${certdir}/ca-key.pem" 4096
fi

# setup a CA cert
openssl req -new -x509 -days 365 \
  -subj "/CN=Local CA" \
  -key "${certdir}/ca-key.pem" \
  -sha256 -out "${certdir}/ca.pem"

# setup a host key
if [ ! -f "${certdir}/key.pem" ]; then
  openssl genrsa -out "${certdir}/key.pem" 2048
fi

# create a signing request
extfile="${certdir}/extfile"
openssl req -subj "/CN=${host}" -new -key "${certdir}/key.pem" \
   -out "${certdir}/${host}.csr"
echo "subjectAltName = IP:192.168.0.99,IP:127.0.0.1,DNS:server.entwicklung,DNS: devshop.entwicklung, DNS:portainer.entwicklung, DNS:gitea.entwicklung, DNS:pma.entwicklung, DNS:localhost, DNS:*.devhop.entwicklung" > ${extfile}

# create the host cert
openssl x509 -req -days 365 \
   -in "${certdir}/${host}.csr" -extfile "${certdir}/extfile" \
   -CA "${certdir}/ca.pem" -CAkey "${certdir}/ca-key.pem" -CAcreateserial \
   -out "${certdir}/cert.pem"

# cleanup
if [ -f "${certdir}/${host}.csr" ]; then
        rm -f -- "${certdir}/${host}.csr"
fi
if [ -f "${extfile}" ]; then
        rm -f -- "${extfile}"
fi

openssl req -x509 -subj "/C=DE/ST=NRW/L=Aachen/O=IT-Beratung & Softwareentwicklung Joerg Riemenschneider/OU=Webdevelopment/CN=${wildcardhost}" -nodes -days 365 -newkey rsa:2048 -keyout ${certdir}/wildcard.key -out ${certdir}/wildcard.crt
