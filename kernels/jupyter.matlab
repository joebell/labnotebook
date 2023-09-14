docker run -it --rm \
    -v labnotebook-homedirs:/home \
    -v labnotebook-etc:/etc \
    --network=host \
    matlab:latest jupyter notebook --ip 0.0.0.0 --port 8888 --allow-root
