#!/bin/bash
# This script installs the requirements for the Helix installation.

clear				# clear terminal window

echo "Welcome to Helix Sandbox Intallation, please chose between one of the following options for proceeding with instalation."

echo

echo "Type [1] for install helix with COaP or type [2] for installing Helix with MQTT"

read type

echo "Updating Ubuntu"

sudo apt -y update
sudo apt -y upgrade

echo "Ubuntu is updated!"

echo "Installing Docker Engine and Docker compose."

# Install prerequisites
sudo apt-get -y update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
sudo apt-get -y install sed

# Add docker's package signing key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add repository
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install latest stable docker stable version
sudo apt-get -y update
sudo apt-get -y install docker-ce

# Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod a+x /usr/local/bin/docker-compose

# Enable & start docker
sudo systemctl enable docker
sudo systemctl start docker

echo "Docker Engine and Docker compose installed with success."

# Installing Helix Sandbox with MQTT
if [[ $type -eq 2 ]]
then
  echo "Installing Helix Sandbox with MQTT"
  echo 'Enter the IP address of the server'
  read MYIP
  echo 'Enter local ip'
  read MYIPlocal
  git clone https://github.com/fabiocabrini/Helix_IoT_MQTT.git
  cd Helix_IoT_MQTT
  chmod +x docker-compose.yml
  mv docker-compose.yml docker-compose-old.yml
  sed "s/<HELIX_SANDBOX_IP>/$MYIPlocal/g" docker-compose-old.yml > docker-compose-old2.yml
  sed "s/<HELIX_IOT_IP>/$MYIP/g" docker-compose-old2.yml > docker-compose.yml
  
  rm -rf docker-compose-old2.yml
  rm -rf docker-compose-old.yml

  sudo docker-compose up -d

else

  echo "Installing Helix Sandbox with COaP"
  echo "Pulling Docker Images"

  sudo docker pull mongo:3.4
  sudo docker pull fiware/orion:latest
  sudo docker pull fiware/cygnus-ngsi:1.9.0
  sudo docker pull m4n3dw0lf/dtls-lightweightm2m-iotagent

  echo "Images pulled with success"

  echo "Creating Keys"
  sudo mkdir -p /opt/secrets
  sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /opt/secrets/ssl_key -out /opt/secrets/ssl_crt "/C=BR /ST=SP /L=SP /O=Personal /OU=Personal /CN=Helix"

  git clone https://github.com/fabiocabrini/helix-sandbox.git
  cd helix-sandbox/compose
  echo "put_here_your_encryption_key" > secrets/aes_key.txt
  sudo docker-compose up -d
fi

echo "Helix installed with success"
