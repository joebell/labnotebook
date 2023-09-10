docker run -it --rm \
    -v labnotebook-homedirs:/home \
    -v labnotebook-etc:/etc \
    --user 1000 \
    matlab:latest matlab --nosplash --nodesktop
