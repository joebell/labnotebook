#!/bin/bash

docker build -f ./labnotebook.dockerfile -t labnotebook:latest .

# Remove old volumes
docker ps -a --filter "volume=labnotebook-homedirs" | xargs docker rm -f
docker volume rm -f labnotebook-*

# Create new volumes
docker volume create labnotebook-homedirs
# docker volume create labnotebook-etc
docker volume create labnotebook-authdata
# Can I symlink passwd, shadow, group, and .sqlite from /etc/users?
