#!/usr/bin/env bash

## script for update exisiting installs

docker-compose -f /var/team-development-server/docker-compose.yml stop
docker-compose -f /var/team-development-server/docker-compose.yml pull
docker-compose -f /var/team-development-server/docker-compose.yml up -d
