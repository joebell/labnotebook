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

# Option 1: --privliged
# https://www.docker.com/blog/docker-can-now-run-within-docker/
# Have not gotten this to work yet...

# Bind mount the docker socket onto the host so containers are siblings
#    -v /var/run/docker.sock:/var/run/docker.sock \
# If /var/run/docker.sock is given docker group ownership then this can setup a kernel, but they don't run.
# This might be solvable with some dive into dockernel

# Will try sysbox too:
#    --runtime=sysbox-runc \
# This works but doesn't have GPU support! (and it doesn't look to be on the horizon)

# *** Try podman to contain docker ***
# The GPU support works with 4.6.2 after nvidia-container-toolkit
# Test with: podman run --rm --device nvidia.com/gpu=all ubuntu nvidia-smi -L

# $gpu_option


# ENTRYPOINT ["conda", "run", "-n", "myenv",
# podman run -it --device nvidia.com/gpu=all \
#    -p 49152-65535:49152-65535 \
#    -p 8000:8000 \
docker run $gpu_option -it \
    --network=host \
    -v notebook-homedirs:/home \
    -v notebook-etc:/etc \
    -v /var/run/docker.sock:/var/run/docker.sock \
    $ssl_cert \
    $ssl_key \
    labnotebook:latest

#docker-compose up
