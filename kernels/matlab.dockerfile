# Use the mathworks/matlab base image
FROM labnotebook:latest

EXPOSE 8888

CMD python3 -m jupyter_matlab_kernel -f $DOCKERNEL_CONNECTION_FILE
#CMD python3 -m matlab_kernel -f $DOCKERNEL_CONNECTION_FILE
#CMD python -m ipykernel_launcher -f $DOCKERNEL_CONNECTION_FILE
