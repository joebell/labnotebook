#!/bin/bash

# Persist the whole /etc directory to allow for user persistence
docker run -it -p 8000:8000 -v notebook-homedirs:/home -v notebook-etc:/etc labnotebook:latest
