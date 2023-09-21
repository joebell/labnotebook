#!/bin/bash
#
# run.sh
#
# Starts the labnotebook system running.
#
#

# Place paths to SSL cert and key here
ssl_cert="/etc/ssl/gait_mednet_ucla_edu.pem"
ssl_key="/etc/ssl/private/gait.mednet.ucla.edu.key"


# Check if either ssl_cert or ssl_key is empty
if [ -z "$ssl_cert" ] || [ -z "$ssl_key" ]; then
    echo "Using self-signed SSL certificates."
    USE_SSL="false"
    ssl_cert_option=""
    ssl_key_option=""
else
    echo "Using externally signed SSL certificates."
    USE_SSL="true"
    ssl_cert_option="-v $ssl_cert:/etc/jupyterhub/ssl/my_cert.crt "
    ssl_key_option="-v $ssl_key:/etc/jupyterhub/ssl/my_key.key "
fi

# Check if NVIDIA kernel module is loaded
if lsmod | grep -q "nvidia"; then
    echo "NVIDIA kernel module is loaded."
    USE_GPU="true"
    gpu_option="--gpus all"
else
    echo "NVIDIA kernel module is not loaded."
    USE_GPU="false"
    gpu_option=""
fi

# Get the Docker group ID in the host to match it in the container
DOCKER_GROUP_ID=$(getent group docker | cut -d: -f3)
DOCKER_RUN_COMMAND="docker run \
    --init \
    --restart unless-stopped \
    --name labnotebook \
    -e "USE_GPU=$USE_GPU" \
    $gpu_option \
    --network=host \
    -v labnotebook-homedirs:/home \
    -v labnotebook-etc:/etc \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e "USE_SSL=$USE_SSL" \
    -e "DOCKER_GROUP_ID=$DOCKER_GROUP_ID" \
    $ssl_cert_option \
    $ssl_key_option \
    labnotebook:latest"


# Check if a container named "labnotebook" exists
if docker ps -a --format '{{.Names}}' | grep -q '^labnotebook$'; then
    echo "A container named 'labnotebook' already exists."
    read -p "Do you want to restart it? (y/n): " choice
    if [ "$choice" == "y" ]; then
        docker start labnotebook
        echo "Container 'labnotebook' has been restarted."
    else
        # Remove the existing container
        docker rm labnotebook
        echo "Container 'labnotebook' has been removed."

        # Start a new container
        eval $DOCKER_RUN_COMMAND
    fi
else
    # Container does not exist, so start a new one
    eval $DOCKER_RUN_COMMAND
fi

