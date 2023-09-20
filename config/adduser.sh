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
usermod -aG lab $USERNAME

# Adjust home directory permissions to ensure lab group has r+x
mkdir /home/$USERNAME/.matlab
cp /build/config/matlab_license.lic /home/$USERNAME/.matlab
chown -R $USERNAME:lab /home/$USERNAME
chmod -R 755 /home/$USERNAME
chmod g+s /home/$USERNAME
ln -s /build/config/README.txt /home/$USERNAME/README.txt
ln -s /home/shared /home/$USERNAME/shared

# Init conda for users
sudo -u $USERNAME /opt/conda/bin/conda init
# Set the default environment
echo "conda activate jupyterenv" >> /home/$USERNAME/.bashrc

# Create SSH keys
sudo -u $USERNAME ssh-keygen -t ed25519 -C "$USERNAME@labnotebook" -N "" -f "/home/$USERNAME/.ssh/id_ed25519"



