#!/bin/bash

# Persist the whole /etc directory to allow for user persistence
docker run --gpus all -it -p 9000:8000 \
    -v notebook-homedirs:/home \
    -v notebook-etc:/etc \
    -v /etc/ssl/gait_mednet_ucla_edu.pem:/etc/jupyterhub/ssl/my_cert.crt \
    -v /etc/ssl/private/gait.mednet.ucla.edu.key:/etc/jupyterhub/ssl/my_key.key \
    labnotebook:latest
