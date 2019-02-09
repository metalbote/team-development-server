#!/usr/bin/env bash

echo "######  Are all dockers running?"

# Proxy
if docker ps --filter="name=tds_proxy" -q; then
  echo "Proxy is running!"
  STATUS=0
else
  echo "Proxy is NOT running."
  STATUS=1
fi

# Portainer
if docker ps --filter="name=tds_portainer" -q; then
  echo "Portainer is running!"
  STATUS=0
else
  echo "Portainer is NOT running."
  STATUS=1
fi

# Gitea
if docker ps --filter="name=tds_gitea" -q; then
  echo "Gitea is running!"
  STATUS=0
else
  echo "Gitea is NOT running."
  STATUS=1
fi

# mailhog
if docker ps --filter="name=tds_mailhog" -q; then
  echo "Mailhog is running!"
  STATUS=0
else
  echo "Mailhog is NOT running."
  STATUS=1
fi

# phpMyAdmin
if docker ps --filter="name=tds_pma" -q; then
  echo "phpMyAdmin is running!"
  STATUS=0
else
  echo "phpMyAdmin is NOT running."
  STATUS=1
fi

exit $STATUS
