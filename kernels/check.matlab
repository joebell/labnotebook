docker run -it --rm \
    -v labnotebook-homedirs:/home \
    -v labnotebook-etc:/etc \
    --user $(id -u) \
    --network=host \
    matlab:latest python -m matlab_kernel.check
