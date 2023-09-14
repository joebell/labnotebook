# A Docker-ized version of Jupyter (eventually hub) that uses Docker to improve data reproducibility
#

# First, use the MATLAB image to get started with MATLAB
#FROM mathworks/matlab:R2023a as matlab
#
#USER root
#WORKDIR /
#
#RUN python3 -m pip install jupyter-matlab-proxy

# Use the official Ubuntu 22.04 base image
FROM ubuntu:22.04

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Update and upgrade packages
RUN apt-get update && apt-get upgrade -y
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt-get update && apt-get upgrade -y

# Install python, pip, wget, git, vim, sudo, lxml dependencies
RUN apt-get install -y python3.10 python3-pip wget git ca-certificates curl gnupg vim sudo python3-lxml libxslt1-dev

# Install ACL
RUN apt-get update
RUN apt-get install -y acl

# Install docker (in the container) to generate kernel containers
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN chmod a+r /etc/apt/keyrings/docker.gpg
RUN echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Give an admin user with sudo privlidges; it will be created at run-time
RUN echo 'admin ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/admin

# Download and install MATLAB
#
ARG MATLAB_RELEASE=R2023a
ARG MATLAB_INSTALL_LOCATION=/opt/matlab/R2023a
ARG MATLAB_PRODUCT_LIST=MATLAB
RUN apt-get install -y ca-certificates libasound2 libc6 libcairo2 libcairo-gobject2 libcap2 libcrypt1 libcrypt-dev libcups2 libdrm2 libdw1 libgbm1 libgdk-pixbuf2.0-0 libgl1 libglib2.0-0 libgomp1 libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 libgtk-3-0 libice6 libnspr4 libnss3 libodbc1 libpam0g libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libsndfile1 libsystemd0 libuuid1 libwayland-client0 libxcomposite1 libxcursor1 libxdamage1 libxfixes3 libxft2 libxinerama1 libxrandr2 libxt6 libxtst6 libxxf86vm1 linux-libc-dev locales locales-all make net-tools odbcinst1debian2 procps sudo unzip wget zlib1g xvfb
RUN wget -q https://www.mathworks.com/mpm/glnxa64/mpm \ 
    && chmod +x mpm \
    && ./mpm install \
    --release=${MATLAB_RELEASE} \
    --destination=${MATLAB_INSTALL_LOCATION} \
    --products ${MATLAB_PRODUCT_LIST} \
    || (echo "MPM Installation Failure. See below for more information:" && cat /tmp/mathworks_root.log && false) \
    && rm -f mpm /tmp/mathworks_root.log \
    && ln -s ${MATLAB_INSTALL_LOCATION}/bin/matlab /usr/local/bin/matlab
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/matlab/R2023a/bin/glnxa64

# Download and install Conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

# Add Conda to the PATH
ENV PATH="/opt/conda/bin:${PATH}"

# Update Conda and install Jupyter Notebook
RUN conda update -n base -c defaults conda 
COPY environment.yml /etc
RUN conda env create -f /etc/environment.yml

#RUN pip install matlabengine
#RUN pip install matlab_kernel

# Clean up
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy everything from the build directory for reference
COPY . /build
RUN chmod -R 775 /build

# Setup jupyterhub configuration
RUN mkdir /etc/jupyterhub
RUN ln -s /build/config/jupyterhub_config.py /etc/jupyterhub/jupyterhub_config.py
# Create self-signed SSL certificates for jupyterhub, ideally these are replaced
# at run-time with externally signed certs.
RUN mkdir /etc/jupyterhub/ssl
RUN openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/jupyterhub/ssl/my_key.key \
    -out /etc/jupyterhub/ssl/my_cert.crt -days 365 \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=example.com"

# Default user information for newly created users
RUN ln -s /build/config/adduser.sh /etc/adduser.sh
RUN chmod 774 /build/config/adduser.sh
# Setup default groups and permission
RUN groupadd lab
RUN mkdir /home/share 
RUN chown -R :lab /home && chmod -R 755 /home
RUN chmod g+s /home
RUN chown -R :lab /home/share && chmod -R 775 /home/share
RUN chmod g+s /home/share
RUN setfacl -Rdm g:lab:rwx /home/share

## Copy MATLAB in from the mathworks image
#COPY --from=matlab /usr/local/bin/matlab /usr/local/bin/matlab
#COPY --from=matlab /opt/matlab /opt/matlab
#RUN mkdir /usr/local/bin/util
#RUN ln -s /opt/matlab/R2023a/bin/util/arch.sh /usr/local/bin/util/arch.sh
## Setup MATLAB environment variables
#ENV MW_CONTEXT_TAGS=MATLAB:DOCKERHUB:V1
#ENV USAGE=cloud
#ENV MHLM_CONTEXT=MATLAB_DOCKERHUB
#ENV MWI_APP_PORT=8888
#ENV VARIANTmatlab=matlabLNU


# Expose the Jupyter Notebook port
EXPOSE 8000

# Activate the conda environment on the PATH
ENV PATH /opt/conda/envs/jupyterenv/bin:$PATH

# SHELL ["conda", "run", "-n", "jupyterenv", "/bin/bash", "-c"]
# CMD ["/bin/bash"]
# RUN /sbin/init
#CMD ["/sbin/init && exec /bin/bash"]
#CMD ["jupyterhub","-f","/etc/jupyterhub/jupyterhub_config.py"]

CMD ["/build/startserver.sh"]
