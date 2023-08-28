#!/bin/bash

ADMINPASS="password"
#docker run -it -p 8000:8000 -e JPY_ADMIN_PASSWORD=$ADMINPASS labnotebook:latest
# Persist the whole /etc directory to allow for user persistence
docker run -it -p 8000:8000 -v notebook-homedirs:/home -v notebook-etc:/etc labnotebook:latest
