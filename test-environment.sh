#!/usr/bin/env bash

source .env

export TDS_DOMAINNAME=$TDS_DOMAINNAME
export TDS_VOLUMEDIR=$TDS_VOLUMEDIR

STATUS=0

echo "###### Are all dockers running?"

# Proxy
if docker ps --filter="name=proxy" -q; then
  echo "Proxy is running!"
  $STATUS=0
else
  echo "Proxy is NOT running."
$STATUS=1
fi

# Portainer
if docker ps --filter="name=portainer" -q; then
  echo "Portainer is running!"
  $STATUS=0
else
  echo "Portainer is NOT running."
$STATUS=1
fi

echo "###### Are all dockers reachable via http?"

# Proxy
if curl -s http://proxy.$TDS_DOMAINNAME | grep -q '<a href="/dashboard/">Found</a>'; then
  echo "Proxy is reachable!"
  $STATUS=0
else
  echo "Proxy is NOT reachable!"
  $STATUS=1
fi

# Portainer
if curl -s http://portainer.$TDS_DOMAINNAME | grep -q '<a href="/dashboard/">Found</a>'; then
  echo "Portainer is reachable!"
  $STATUS=0
else
  echo "Portainer is NOT reachable!"
  $STATUS=1
fi





exit $STATUS
