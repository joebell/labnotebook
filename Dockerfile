# A Docker-ized version of Jupyter (eventually hub) that uses Docker to improve data reproducibility

# Use the official Ubuntu 22.04 base image
FROM ubuntu:22.04

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Update and upgrade packages
RUN apt-get update && apt-get upgrade -y

# Install python, pip, wget, git
RUN apt-get install -y python3.11 python3-pip wget git ca-certificates curl gnupg


# Install docker (in-docker) to generate kernel containers
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN chmod a+r /etc/apt/keyrings/docker.gpg
RUN echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Download and install Conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

# Add Conda to the PATH
ENV PATH="/opt/conda/bin:${PATH}"

# Update Conda and install Jupyter Notebook
RUN conda update -n base -c defaults conda 

COPY environment.yml .
RUN conda env create -f environment.yml

# Need Vim, move back to the top
RUN apt-get install -y vim sudo

# Activate the Conda environment
SHELL ["conda", "run", "-n", "jupyterenv", "/bin/bash", "-c"]

# Install the native authenticator
RUN pip install jupyterhub-nativeauthenticator

# Install dockernel. Note that this is not from the package maintainer; this version has a needed bug fix
# Dockernel will be used to help install kernels that run in docker containers
RUN pip install git+https://github.com/tompccs/dockernel.git

# Clean up
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Setup jupyterhub configuration
COPY ./config/jupyterhub_config.py /etc/jupyterhub/

# Expose the Jupyter Notebook port
EXPOSE 8000

# Make an admin user; actually just do this with login hooks on first use
# RUN useradd -ms /bin/bash admin

# Activate the conda environment
ENV PATH /opt/conda/envs/jupyterenv/bin:$PATH
#ENTRYPOINT ["conda", "run", "-n", "jupyterenv", "/bin/bash", "-c"]
CMD ["/bin/bash"]
