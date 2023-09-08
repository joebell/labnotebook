#!/bin/bash

chmod 777 /var/run/docker.sock
#/bin/bash
jupyterhub -f /etc/jupyterhub/jupyterhub_config.py
