#!/bin/bash

sleep 3m
source /var/team-development-server/.env

echo "###### Are all dockers reachable via http?"

# Proxy
curl -s http://proxy.$TDS_DOMAINNAME | cat
#if curl -s http://proxy.$TDS_DOMAINNAME | cat |  grep -q '<a href="/dashboard/">Found</a>'; then
#  echo "Proxy is reachable!"
#  STATUS=0
#else
#  echo "Proxy is NOT reachable!"
#  STATUS=1
#fi

# Portainer
curl -s http://portainer.$TDS_DOMAINNAME | cat
#if curl -s http://portainer.$TDS_DOMAINNAME | cat |  grep -q '<html lang="en" ng-app="portainer">'; then
#  echo "Portainer is reachable!"
#  STATUS=0
#else
#  echo "Portainer is NOT reachable!"
#  STATUS=1
#fi

# Gitea
GITEA_INSTALL= curl -s http://gitea.$TDS_DOMAINNAME | cat | grep -q '<meta name="author" content="Gitea - Git with a cup of tea" />';
GITEA_RUN= curl -s http://gitea.$TDS_DOMAINNAME | cat | grep -q '<a href="/explore">Found</a>';
curl -s http://gitea.$TDS_DOMAINNAME | cat
#if $GITEA_RUN || $GITEA_INSTALL; then
#  echo "Gitea is reachable!"
#  STATUS=0
#else
#  echo "Gitea is NOT reachable!"
#  STATUS=1
#fi

# Mailhog
curl -s http://mail.$TDS_DOMAINNAME | cat
#if curl -s http://mail.$TDS_DOMAINNAME | cat |  grep -q '<img src="images/hog.png" height="20" alt="MailHog">'; then
#  echo "Mailhog is reachable!"
#  STATUS=0
#else
#  echo "Mailhog is NOT reachable!"
#  STATUS=1
#fi

# phpMyAdmin
curl -s http://pma.$TDS_DOMAINNAME | cat
#if curl -s http://pma.$TDS_DOMAINNAME | cat |  grep -q '<a href="./url.php?url=https%3A%2F%2Fwww.phpmyadmin.net%2F" target="_blank" rel="noopener noreferrer" class="logo">'; then
#  echo "phpMyAdmin is reachable!"
#  STATUS=0
#else
#  echo "phpMyAdmin is NOT reachable!"
#  STATUS=1
#fi


exit $STATUS
