# Start from the Ubuntu 22.04 base
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install python, pip, wget, git, vim, sudo, acl
# Install latex and xetex for PDF output
RUN apt-get update
RUN apt-get install -y python3.10 python3-pip wget git ca-certificates curl gnupg vim sudo acl texlive-xetex texlive-fonts-recommended texlive-plain-generic

# Install Docker to allow creation of compute kernels
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN chmod a+r /etc/apt/keyrings/docker.gpg
RUN echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Create a sudo group
# Give an admin user with sudo privlidges; it will be created at run-time
RUN echo 'admin ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/admin
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/sudogroup

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
RUN conda init
# Activate the conda environment on the PATH
ENV PATH $PATH:/opt/conda/envs/jupyterenv/bin

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

# Setup default groups and permission, shared directory
RUN groupadd lab
COPY ./shared /home/shared
RUN mkdir /home/shared/readonly
RUN chown -R :lab /home && chmod -R 755 /home
RUN chmod g+s /home
RUN chown -R :lab /home/shared && chmod -R 775 /home/shared
RUN chmod g+s /home/shared
RUN setfacl -Rdm g:lab:rwx /home/shared
RUN chown -R root:lab /home/shared/readonly
RUN chmod -R 755 /home/shared/readonly
RUN setfacl -m u:root:rwX,g:lab:rX /home/shared/readonly

# Expose the Jupyter Notebook port
EXPOSE 8000

# Get JupyterHub to use bash in terminals
ENV SHELL=/bin/bash

ENTRYPOINT []
CMD ["/build/startserver.sh"]

