# Use the mathworks/matlab base image
FROM mathworks/matlab:R2023a

USER root
WORKDIR /

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/matlab/R2023a/bin/glnxa64

# Install git and node (needed for pip to pull from github)
RUN apt-get update
RUN apt-get install -y ca-certificates curl gnupg git

#RUN mkdir -p /etc/apt/keyrings
#RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
#ENV NODE_MAJOR=20
#RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
#RUN apt-get update
#RUN apt-get install nodejs -y

RUN python3 -m pip install jupyter
RUN pip install --upgrade pip ipython ipykernel
RUN pip install git+https://github.com/joebell/dockernel.git
RUN pip install matlabengine
RUN pip install matlab_kernel
#RUN python3 -m pip install git+https://github.com/joebell/jupyter-matlab-proxy.git


EXPOSE 8888

#CMD python3 -m jupyter_matlab_kernel -f $DOCKERNEL_CONNECTION_FILE
CMD python3 -m matlab_kernel -f $DOCKERNEL_CONNECTION_FILE
#CMD python -m ipykernel_launcher -f $DOCKERNEL_CONNECTION_FILE
