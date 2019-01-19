#!/usr/bin/env bash

source ../.env

export TDS_DOMAINNAME=$TDS_DOMAINNAME
export TDS_VOLUMEDIR=$TDS_VOLUMEDIR

if curl -s http://proxy.$TDS_DOMAINNAME | grep -q '<a href="/dashboard/">Found</a>'; then
  echo "Proxy is reachable!"
  exit 0
else
  echo "Tests failed!"
  exit 1
fi
