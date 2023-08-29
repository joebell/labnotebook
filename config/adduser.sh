#!/bin/bash
#
# Script for setting up new Jupyterhub users
#
# useradd automatically copies the contents of /etc/skel

USERNAME=$1

echo '******** adduser.sh **********'
echo $USERNAME
# Add every created user to the docker group
usermod -aG docker $USERNAME
ln -s /build/config/README.txt /home/$USERNAME/README.txt
