# Docker install scripts
This repo contains an install script for docker and for portainer. 

## Installation

### Make install scripts executable
```bash
sudo chmod +x installDocker.sh
sudo chmod +x installPortainer.sh
```

### Install Docker
When asked, press 'y' 

_ignore warnings during install. All will be well after a reboot. This happens automatically at the end of the installDocker.sh script_

```bash
./installDocker.sh
```

### Install docker-compose & portainer
When asked, press 'y' 

_ignore warnings during install. All will be well after a reboot. This happens automatically at the end of the installDocker.sh script_

```bash
./installPortainer.sh
```

### Post-installation
You can now deploy containers with docker, docker-compose or portainer.
Portainer is available @ 'http://<ip_address_pi>:9000/'

Create Admin user 
Choose local environment like 

![PortainerEnvironment](../lib/PortainerEnvironment.png)

Once done, you're in the home screen. 
Press local to enter the environment and start deploying containers.
                                                    
![PortainerHome](../lib/PortainerHome.png)

## Static IP
Just a reminder to set a static ip

_edit file_
```bash
sudo nano /etc/dhcpcd.conf
```
Choose an ip address like '192.168.0.20'

Replace ip after 'static ip_address=' and copy/paste the whole section at the end of the dhcpcd.conf file

if you are __NOT__ using wifi, change 'wlan0' to 'eth0'

```bash
interface wlan0
static ip_address=192.168.0.20/24
static routers=192.168.0.1
static domain_name_servers=192.168.0.1 1.1.1.1 1.0.0.1
```
