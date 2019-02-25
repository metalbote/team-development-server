# Team Development Server [![Build Status](https://travis-ci.org/metalbote/team-development-server.svg?branch=master)](https://travis-ci.org/metalbote/team-development-server)
> Scripts and Template for setting up a development server for small teams based on dockers

## Notice 
This is a work in progress and more playground for my personal development environment, but i wanted to share and maybe it's a good starting point for your own.

For now it consists of:
 - Traefik for reverse proxying the other services
 - Portainer for easy docker management and to quickly spin up your own containers
 - Gitea as git repository frontend - lightweight and easy with most necessary functionality
  

## Requirements

This is meant to be used on a freshly installed linux system, that should operate as your team server. The best way to start is a minimal installation. It doesn't matter if it is a VM or a bare metal machine. I personally run a VM with CentOS 7 and openSUSE Kubic bare metal with this configuration, and travis build takes place on ubuntu.
But make sure that you have the following installed or configured:
- network with a static ip
- dns domain resolving to your system
- ssh access to your system 
- docker-ce & docker-compose installed and running (DockerEngine 18.02.0+)
  
## Getting started

1. Get the install script with
   ``` bash
   wget https://raw.githubusercontent.com/metalbote/team-development-server/master/install.sh 
   ```
2. Run to setup the needed packages etc:
   ``` bash
   bash install.sh 
   ```
3. Follow instructions aka edit the `.env` file according to your needs.
4. Run to create and start the containers with your config 
   ``` bash
   bash start-containers.sh
   ```
5. Visit `http://proxy.<yourdomain.com>` to verify all containers running and have correct proxying
6. Visit `http://portainer.<yourdomain.com>` and do all your docker/container stuff
7. Visit `http://gitea.<yourdomain.com>` and finish install configuration. Most of the settings are already configured correctly and have been taken from the .env file. Only Email resp. Admin have to be configured.
8. Have fun with playing around
