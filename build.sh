#!/bin/bash

docker build -t labnotebook:latest .

# Remove old volumes
docker volume rm -f notebook-homedirs
docker volume rm -f notebook-etc
docker volume create notebook-homedirs
docker volume create notebook-etc
