#!/bin/bash

groupmod -g $DOCKER_GROUP_ID docker
chmod 660 /var/run/docker.sock
conda init
/opt/conda/envs/jupyterenv/bin/jupyterhub -f /etc/jupyterhub/jupyterhub_config.py
