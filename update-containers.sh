#!/bin/bash

## script for update exisiting installs
echo -e "\e[32m#### Stop all team-development-server containers...\e[0m" 2>&1 | tee ./setup.log
sudo docker-compose -f /var/team-development-server/docker-compose.yml stop
echo -e "\e[32m#### Pull all team-development-server images...\e[0m" 2>&1 | tee ./setup.log
sudo docker-compose -f /var/team-development-server/docker-compose.yml pull
echo -e "\e[32m#### Restart all team-development-server.containers...\e[0m" 2>&1 | tee ./setup.log
sudo docker-compose -f /var/team-development-server/docker-compose.yml up -d
