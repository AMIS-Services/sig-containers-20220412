# Intro
This is the README for SIG container technology ( 12-04-2022 )

# Prerequisites
included are install-scripts for the raspberry pi. Follow the README in the 'dockerInstallScriptsRPi' folder.

## docker
You should have a docker engine running on the host. 

- Install docker desktop ( OS = ALL* )

- Install docker on WSL ( WSL = Windows Subsystem for Linux)

- Install docker on Linux

Windows: https://docs.docker.com/desktop/windows/install/
Macos: https://docs.docker.com/desktop/mac/install/
Linux: https://docs.docker.com/engine/install/ubuntu/#install-using-the-convenience-script

> *docker desktop on linux is still in beta

## compose
### docker desktop
docker-compose is installed with docker desktop

### Raspberry Pi
If you are following on a raspberry pi, execute 'installPortainer.sh' or copy/paste the commands in your terminal.

# Portainer
## Docker basic commands 
```
docker version
docker ps
docker volume create portainer_data​
docker pull portainer/portainer-ce:latest ​
docker image ls​
docker run -d --name=portainer portainer/portainer-ce:latest​
docker stop portainer​
docker rm portainer​
```
## Run Portainer
Will work on Windows and linux
```
docker run -d -p 8000:8000 -p 9000:9000 -p 9443:9443 --name=portainer ​--restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest​
```

# Home Assistant

## Intro

Today we are going to see how to install Home Assistant and some complements on docker using a docker-compose file. Consequently, this stack will provide the following services:

    hass, the core of Home Assistant.
    mariadb, to replace the default database engine SQLite.
    mosquitto, a well known open source mqtt broker.
    nodered, a browser-based flow editor to write your automations.
    hass-configurator, a filesystem-browser and text-editor for your configuration files.

In addition, we will be able to install portainer, a web application to manage your containers easily.

This procedure has been tested in arm (Raspberry Pi) and x86_64 architectures. For instructions on how to install docker and docker-compose on your Raspberry Pi you can check [this article](https://iotechonline.com/how-to-install-docker-and-docker-compose-on-your-raspberry-pi/).
.env file

A few environment variables will be declared in a file named .env, in the same directory where the docker-compose file is. As a result, these variables will be populated later into our docker-compose file at the moment the containers are created.
Security advise

The purpose of this stack is to have a working Home Assistant installation with some accessories. This means that it is not secure by default so you should NEVER expose it to the internet as is. I will explain some steps to secure it in a [next article](https://iotechonline.com/home-assistant-panel_iframe-external-access-with-nginx-proxy/), for example how to password protect Node-RED and hass-configurator and how to hide Home Assistant behind a reverse proxy like nginx using ssl certificates.
Preparation

Create a directory where we will put all needed config and our docker-compose file itself. As an example, I will be using a directory named ‘hass’. We will then precreate a directory structure to maintain configuration and data of the services. To clarify, structure will be as shown below and should be created as a normal non-root user.

```
hass
├── configurator-config
│   └── settings.conf
├── docker-compose.yml
├── .env
├── hass-config
│   └── configuration.yaml
├── mariadb
├── mosquitto
│   ├── config
│   │   └── mosquitto.conf
│   ├── data
│   └── log
├── nodered
```

## Prereqs

### configurator-config/settings.conf
```
{
    "BASEPATH": "../hass-config"
}
```

### .env
This file will hold the root password for mariadb and the password for the ha_db database, so fill them with your preferences. PUID and PGID will be the uid and gid of the user who created the directory structure, you can check these ids typing ‘id’ as that user.
```
MYSQL_ROOT_PASSWORD=mariadbrootpassword
HA_MYSQL_PASSWORD=ha_dbdatabasepassword
PUID=1000
PGID=1000
```

### hass-config/configuration.yaml
This will be the basic configuration file for Home Assistant, replace <hostip> with the internal ip of the host where the docker engine is installed and <ha_dbdatabasepassword> with the password you chose for the ha_db database
```
default_config:
panel_iframe:
  configurator:
    title: Configurator
    icon: mdi:wrench
    url: http://<hostip>:3218/
    require_admin: true
  nodered:
    title: Node-Red
    icon: mdi:shuffle-variant
    url: http://<hostip>:1880/
    require_admin: true
mqtt:
#  broker: <hostip>
  
recorder:
  db_url: mysql://homeassistant:<ha_dbdatabasepassword>@<hostip>/ha_db?charset=utf8
  purge_keep_days: 30
```

### mosquitto/config/mosquitto.conf
minimal config for mosquitto
```
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
listener 1883
allow_anonymous true
```

### docker-compose.yaml
Finally here is our docker-compose.yaml file. As this is a yaml file, be aware about keeping the correct indentation. This file works for Raspberry Pi. For x86_64 architecture you should replace image name of hass-configurator by ‘causticlab/hass-configurator-docker:x86_64’, that’s it.
```
version: '3'
services:
  homeassistant:
    container_name: hass
    image: homeassistant/home-assistant
    volumes:
      - ./hass-config:/config
      - /etc/localtime:/etc/localtime:ro
    restart: unless-stopped
    network_mode: host
    depends_on:
      - mariadb
      - mosquitto

  mariadb:
    image: linuxserver/mariadb
    container_name: mariadb
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
      MYSQL_DATABASE: ha_db
      MYSQL_USER: homeassistant
      MYSQL_PASSWORD: "${HA_MYSQL_PASSWORD}"
      PUID: 1000
      PGID: 1000
    volumes:
      - ./mariadb:/config
    ports:
      - "3306:3306"

  nodered:
    container_name: nodered
    image: nodered/node-red
    ports:
      - "1880:1880"
    volumes:
      - ./nodered:/data
    depends_on:
      - homeassistant
      - mosquitto
    environment:
      TZ: "Europe/Amsterdam"
    restart: unless-stopped

  mosquitto:
    image: eclipse-mosquitto
    container_name: mosquitto
    restart: unless-stopped
    ports:
      - "1883:1883"
      - "1884:1884"
    volumes:
      - "./mosquitto/config:/mosquitto/config"
      - "./mosquitto/data:/mosquitto/data"
      - "./mosquitto/log:/mosquitto/log"
    environment:
      - TZ=Europe/Amsterdam
    user: "${PUID}:${PGID}"

  hass-configurator:
    image: "causticlab/hass-configurator-docker:arm"
    container_name: hass-configurator
    restart: unless-stopped
    ports:
      - "3218:3218/tcp"
    depends_on:
      - homeassistant
    volumes:
      - "./configurator-config:/config"
      - "./hass-config:/hass-config"
    user: "${PUID}:${PGID}"
```

## Run Stack

### docker-compose
Start in the directory where your docker-compose.yaml file resides. eg:
```cd ~/hass```

__Start__:
```docker-compose up```

_Option_: 
Detached Mode: ```-d```

```docker-compose up -d```

__Stop__:
```docker-compose down```

_Option_:
Delete Volume: ```-v```

```docker-compose down -v```

## Add portainer to config file
```
 portainer:
   title: Portainer
   url: http://<hostip>:9000/
   icon: mdi:docker
   require_admin: true
```

## Troubleshooting
Review the container logs.
Most common issues are permission related.
On RPi solve it like:
```
sudo chown 1883:1883 ./mosquitto/config/mosquitto.conf
```

