#!/bin/bash

chmod 777 /var/run/docker.sock
/opt/conda/envs/jupyterenv/bin/jupyterhub -f /etc/jupyterhub/jupyterhub_config.py
