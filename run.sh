#!/bin/bash

# Check if NVIDIA kernel module is loaded
if lsmod | grep -q "nvidia"; then
    echo "NVIDIA kernel module is loaded."
    gpu_option="--gpus all"
else
    echo "NVIDIA kernel module is not loaded."
    gpu_option=""
fi

ssl_cert="-v /etc/ssl/gait_mednet_ucla_edu.pem:/etc/jupyterhub/ssl/my_cert.crt "
ssl_key="-v /etc/ssl/private/gait.mednet.ucla.edu.key:/etc/jupyterhub/ssl/my_key.key "

#ssl_cert=""
#ssl_key=""

docker run $gpu_option -it -p 9000:8000 \
    -v notebook-homedirs:/home \
    -v notebook-etc:/etc \
    $ssl_cert \
    $ssl_key \
    labnotebook:latest

#docker-compose up
