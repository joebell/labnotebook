docker run -it --rm \
    -v labnotebook-homedirs:/home \
    -v labnotebook-etc:/etc \
    --network=host \
    --user 1001 \
    matlab:latest /bin/sh
