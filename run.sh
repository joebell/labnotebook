#!/bin/bash

# Place paths to SSL cert and key here
ssl_cert="/etc/ssl/gait_mednet_ucla_edu.pem"
ssl_key="/etc/ssl/private/gait.mednet.ucla.edu.key"

# Place path to MATLAB license here
matlab_license=""



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


docker run -it \
    -e "USE_GPU=$USE_GPU" \
    $gpu_option \
    --network=host \
    -v notebook-homedirs:/home \
    -v notebook-etc:/etc \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e "USE_SSL=$USE_SSL" \
    $ssl_cert_option \
    $ssl_key_option \
    labnotebook:latest

#docker-compose up
