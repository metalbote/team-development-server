#!/usr/bin/env bash

source .env

export TDS_DOMAINNAME=$TDS_DOMAINNAME
export TDS_VOLUMEDIR=$TDS_VOLUMEDIR

STATUS=0

echo "###### Are all dockers running?"
if docker ps --filter="name=proxy" -q; then
  echo "Proxy is running!"
  $STATUS=0
else
  echo "Proxy is NOT running."
$STATUS=1
fi



echo "###### Are all dockers reachable via http?"
if curl -s http://proxy.$TDS_DOMAINNAME | grep -q '<a href="/dashboard/">Found</a>'; then
  echo "Proxy is reachable!"
  $STATUS=0
else
  echo "Proxy is NOT reachable!"
  $STATUS=1
fi






exit $STATUS
