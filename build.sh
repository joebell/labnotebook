#!/bin/bash
#
# build.sh
#
# This script builds the labnotebook container from the dockerfile. It will ask if the volumes 
# containing /home and /etc data should be overwritten.
#
#

# Remove any old labnotebook containers
echo "Deleting old labnotebook container..."
docker rm -f labnotebook

# Build the new container
docker build -f ./labnotebook.dockerfile -t labnotebook:latest .

# Check if the Docker volumes exist before over-writing them
if docker volume inspect labnotebook-homedirs >/dev/null 2>&1; then
    echo "Docker volume 'labnotebook-homedirs' already exists."
    echo "Do you want to delete and replace it with a new volume?"
    read -p "(This will permanently delete all data mounted to /home) (y/n): " answer
    if [ "$answer" == "y" ]; then
        echo "Deleting the existing volume..."
        docker volume rm -f labnotebook-homedirs
        echo "Creating a new volume..."
        docker volume create labnotebook-homedirs
        echo "New volume 'labnotebook-homedirs' created."
    else
        echo "Keeping the existing volume 'labnotebook-homedirs'."
    fi
else
    echo "Creating new volume 'labnotebook-homedirs'."
    docker volume create labnotebook-homedirs
fi

if docker volume inspect labnotebook-etc >/dev/null 2>&1; then
    echo "Docker volume 'labnotebook-etc' already exists."
    echo "Do you want to delete and replace it with a new volume?"
    read -p "(This will permanently delete the configuration from /etc) (y/n): " answer
    if [ "$answer" == "y" ]; then
        echo "Deleting the existing volume..."
        docker volume rm -f labnotebook-etc
        echo "Creating a new volume..."
        docker volume create labnotebook-etc
        echo "New volume 'labnotebook-etc' created."
    else
        echo "Keeping the existing volume 'labnotebook-etc'."
    fi
else
    echo "Creating new volume 'labnotebook-etc'."
    docker volume create labnotebook-etc
fi
