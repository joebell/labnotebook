#!/bin/bash

docker build -f ./labnotebook.dockerfile -t labnotebook:latest .

# Remove old volumes
docker ps -a --filter "volume=labnotebook-homedirs" | xargs docker rm -f
docker volume rm -f labnotebook-homedirs
docker volume rm -f labnotebook-etc

# Create new volumes
docker volume create labnotebook-homedirs
docker volume create labnotebook-etc
