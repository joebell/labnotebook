docker run -it --rm \
    -v labnotebook-homedirs:/home \
    -v labnotebook-etc:/etc \
    --user $(id -u) \
    --network=host \
    matlab:latest matlab -nosplash -nodesktop
#    matlab:latest /bin/bash
#    matlab:latest matlab -nosplash -nodesktop
#    --user $(id -u) \
