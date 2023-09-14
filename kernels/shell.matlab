docker run -it --rm \
    -v labnotebook-homedirs:/home \
    -v labnotebook-etc:/etc \
    --network=host \
    matlab:latest /bin/bash
