# Use the mathworks/matlab base image
FROM mathworks/matlab:R2023a

USER root
WORKDIR /

RUN python3 -m pip install jupyter-matlab-proxy

CMD python3 -m jupyter_matlab_kernel -f $DOCKERNEL_CONNECTION_FILE
