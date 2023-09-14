# Use the mathworks/matlab base image
FROM labnotebook:latest

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/matlab/R2023a/bin/glnxa64

RUN pip install matlabengine
RUN pip install matlab_kernel
#RUN python3 -m pip install git+https://github.com/joebell/jupyter-matlab-proxy.git

EXPOSE 8888

#CMD python3 -m jupyter_matlab_kernel -f $DOCKERNEL_CONNECTION_FILE
CMD python3 -m matlab_kernel -f $DOCKERNEL_CONNECTION_FILE
#CMD python -m ipykernel_launcher -f $DOCKERNEL_CONNECTION_FILE
