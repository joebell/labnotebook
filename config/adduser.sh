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
chown -R :lab /home/$USERNAME
chmod -R 755 /home/$USERNAME
chmod g+s /home/$USERNAME
ln -s /build/config/README.txt /home/$USERNAME/README.txt

# Init conda for users
sudo -u $USERNAME /opt/conda/bin/conda init
# Set the default environment
echo "conda activate jupyterenv" >> /home/$USERNAME/.bashrc

# Make sure the MATLAB env variable is set
echo "export VARIANTmatlab=matlabLNU" >> /home/$USERNAME/.bashrc

