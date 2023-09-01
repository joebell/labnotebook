#!/bin/bash

docker build -f ./labnotebook.dockerfile -t labnotebook:latest .

# Remove old volumes
docker ps -a --filter "volume=notebook-homedirs" | xargs docker rm -f
docker volume rm -f notebook-homedirs
docker volume rm -f notebook-etc

# Create new volumes
docker volume create notebook-homedirs
docker volume create notebook-etc
