#!/bin/bash
#
# build.sh
#
# This script builds the labnotebook container from the dockerfile. It will ask if the volumes 
# containing /home and /etc data should be overwritten.
#
#

# Check if the container named "labnotebook" exists
if docker ps -a --format '{{.Names}}' | grep -q '^labnotebook$'; then
    # Stop the container if it is running
    if docker ps --format '{{.Names}}' | grep -q '^labnotebook$'; then
        echo "Stopping existing container: labnotebook"
        docker stop labnotebook
    fi

    # Remove the container
    echo "Removing existing container: labnotebook"
    docker rm -f labnotebook
else
    echo "No existing labnotebook container."
fi

# Build the new container
echo "Building a labnotebook container..."
docker build -f ./labnotebook.dockerfile -t labnotebook:latest .

# Define a list of Docker volume names
volume_names=("labnotebook-homedirs" "labnotebook-etc")

# Loop through each volume in the list
for volume_name in "${volume_names[@]}"; do
    # Check if the volume exists
    if docker volume inspect "$volume_name" &> /dev/null; then
        echo "Volume '$volume_name' exists."

        # Ask the user if they want to delete and replace the volume
        read -p "Do you want to delete and replace this volume? (y/n): " choice
        if [ "$choice" == "y" ]; then
            # Query Docker for containers using the volume
            containers=$(docker ps -a --filter "volume=$volume_name" --format '{{.ID}}')
            
            # Stop and remove containers using the volume
            for container_id in $containers; do
                echo "Stopping and removing container: $container_id"
                docker stop "$container_id"
                docker rm -f "$container_id"
            done

            # Remove the volume
            echo "Removing volume: $volume_name"
            docker volume rm -f "$volume_name"

            # Create a new volume with the same name
            echo "Creating a new volume: $volume_name"
            docker volume create "$volume_name"
        else
            echo "Retaining existing volume: $volume_name."
        fi
    else
        echo "Creating a new volume: $volume_name"
        docker volume create "$volume_name"
    fi
done

