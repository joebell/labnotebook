docker build -t matlab:latest -f matlab.dockerfile .

/opt/conda/envs/jupyterenv/bin/dockernel install matlab:latest \
    --name MATLAB-R2023a \
    -v labnotebook-homedirs:/home:rw \
    -v labnotebook-etc:/etc:rw \
    --gpus all \
    --network host \
    --user -1 \
    --group-add -1


