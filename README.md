# Labnotebook
A JupyterHub container designed to allow reproducible research with docker-ized kernels; all in a docker container.

## Purpose

Jupyterhub is a fantastic way to create a shared computing environment for scientific data analysis in a lab, particularly when some of the users may not be technically skilled in a Unix environment. After configuring several of these systems I found I was resolving the same configuration problems multiple times, so elected to container-ize the system I developed into an easy to deploy Docker container. This deployment won't be ideal for everyone, but it's designed to meet the needs of small- to medium-sized labs that want to share data and code among users with varying technical sophistication. 

## Why docker-ize Jupyter kernels?

1. Portability - It's easy to share compute environments in containers.
2. Version control - The compute environment can be documented and tracked, and changes undone.
3. Non-python software - Pip and Conda are great, but docker containers can help port non-python tools.

## Who is this for?

This deployment is designed for small or medium-sized research groups who want to share data, code, and hardware resources by sharing a common development environment, and then easily deploy analyses that can be reproduced on any system. Sharing a common environment is helpful for maintaining privacy and security, because data and code remain centrally located. It can be easily setup with default choices, and the only software dependency it requires is Docker. (SSL encryption keys are strongly recommended, though.) It will work well with python, MATLAB, R and several other languages.

It's not ideal for groups whose size (or compute needs) make sharing a single host impractical, or who don't want to work in a notebook environment.

## Features and choices

- Fully docker-ized deployment. All you need for installation is Docker, SSL certificates, and (optionally) drivers for your GPU, and a MATLAB license.
- An authentication system supervised by the `admin` user allows prospective new users to apply for access and choose their own password.
- Users are given access to the Jupyterhub container but do not have login privliges on the host system.
- To allow for easy reproducibility, Jupyter kernels are run in user-managed Docker containers (using the excellent Dockernel package).
- Kernel containers are sibling-containers, in a Docker-out-of-Docker (DooD) configuration.
- Full support for NVIDIA GPUs in compute kernels.
- By default users have read-only access to all other users' home directories.
- A shared directory /home/shared allows read-write access to files for collaboration.
- A read-only subdirectory /home/shared/readonly allows sharing of source data that should not be modified.

## Security issues

Labnotebook is designed to share a system among a small trusted group, and is intended to allow essentially arbitrary code execution by those trusted users. The system runs in a Docker container, so those users are insulated from unintentionally making changes to the host. However, they are given access to the Docker socket in order to run kernel containers which creates a risk of privlige escalation. 

You should configure SSL certificates to allow users to authenticate the server. (These are mounted in to the Docker container to be used by the Jupyterhub server.) If your machine is visible on the public internet then Let's Encrypt is an excellent way to do generate them. If you are behind an institutional firewall you will need to rely on certificates issued by your institution. Running without SSL is possible, but not recommended.

## Installation and setup

- Install Docker
- Install NVIDIA drivers and nvidia-container-toolkit
- Run build.sh to create the container (and container volumes to store data)
- Run run.sh to run the service
- Navigate to https://[your.ip.address]:8000 
- Click the 'Sign up to create a new user' link to create a new user: the first user must be named `admin`. Set a password.
- After creating the user, choose 'Login with an existing user' and login as the admin user. This will create the admin account, which will have administrative privliges in JupyterHub, and `sudo` privliges.
- Subsequently new users may use the 'Sign up' link to request an account and set a password. The `admin` user must approve their account via the 'Authorize Users' menu. See the [Native-Authenticator Documentation](https://native-authenticator.readthedocs.io/en/stable/quickstart.html#default-workflow) for details.

## Backing-up Data

## Creating a new kernel container

## Generating a stand-alone container for deployment

Once analysis for a publication is finished and you can create a stand-alone container to deploy to other users' machines. Most of the dependencies will already be present in the kernel container, you'll need to develop a new deployment container.

- Ensure any HIPAA protected data has been removed or deidentified
- Copy necessary data to the container
- Copy necessary code to the container
- Ensure the container will run as root to prevent privlige inadequacy issues
- Ensure jupyter notebook is installed in the container and setup to run by default when the container is launched

## Frequenty Asked Questions:

### What system does the JupyterHub shell provide access to? 

This shell is on the containerized system inside the labnotebook Docker container. Users on this system do not (by default) have login access on the parent system, and do not have home directories on the parent system.

### Where is my data? 

User home directories and persistent configuration are stored in Docker named volumes called labnotebook-homedirs and labnotebook-etc. Backing up these two volumes will allow for complete restoration of your system state. These volumes are mounted into /home and /etc, respectively. For normal use it generally makes sense to mount the home directories into the kernel containers so the compute kernels can access data.

### How do I install new software in the LabNotebook system?

In short, you shouldn't install it in the base system. Because the system is in a Docker container, new software packages (with apt, conda, or pip) will not persist if the container is shutdown and restarted. Instead, create a new kernel container that includes the software you'd like to use in your computation. This ensures that your system remains documented and reproducible.

The longer answer is that you can probably re-build the docker image with the software you want, just make sure to preserve your /home and /etc data.

### Can't I just do this with conda and nb_conda_kernels?

Using conda for environment management is very reasonable, but many analysis pipelines wind up using tools outside of python and conda. Working in a Docker kernel ensures the whole compute environment is captured.

### Is this running Docker inside of a Docker container?

Nah, the "outer" Docker container running the JupyterHub server and the "inner" containers running the compute kernels are sister-containers both running under the host's docker daemon. But because the compute kernels are launched from the JupyterHub server, it sort of <i>feels</i> like they are. People sometimes refer to this configuration as Docker-out-of-Docker (DooD).

### I messed up my deployment and want to start over?

Sure, just re-run build.sh and this will create a fresh deployment. (It will erase any data you've uploaded to it.)



# To Do:

- [x] Persist user database in Volumes
- [x] Volume mount home directories
- [x] Script for user setup on creation
- [x] Upgrade Jupyterhub to 4.0
- [x] Install and integrate matlab
- [x] Test Dockernel
- [x] Dockernel GPU support: need to fork the repo to add gpu support in /cli/install.py
- [x] SSL encryption: Working!
- [x] Test GPU support: Working! Requires nvidia-container-toolkit installed on host. Base image includes nvidia-smi to verify.
- [x] Install acl (for setfacl) to maintain permission in /home/share directory
- [x] Symlink /home/shared from /home/$USER/shared
- [ ] Improve dockernel kernel naming
- [ ] Test alternate values for dockernel arguments (user as name, etc)
- [x] Add shared/readonly for data; writable by admin
- [ ] Example image deploy
- [ ] R-kernel
- [x] Figure out how admin can add users as sudoers and admins
- [x] Clean up kernel locations, sample build files
- [ ] Good way to get data in and stored
