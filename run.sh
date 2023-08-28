#!/bin/bash

ADMINPASS="password"
#docker run -it -p 8000:8000 -e JPY_ADMIN_PASSWORD=$ADMINPASS labnotebook:latest
docker run -it -p 8000:8000 labnotebook:latest
