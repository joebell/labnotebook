# labnotebook
A jupyterhub system designed to allow reproducible research with docker-ized kernels; all in a docker container.

## Purpose

Jupyterhub is a fantastic way to create a shared computing environment for scientific data analysis in a lab, particularly when some of the users may not be technically skilled in a Unix environment. After configuring several of these systems I found I was resolving the same configuration problems multiple times, so elected to container-ize the system I developed into an easy to deploy Docker container. This deployment won't be ideal for everyone, but it's designed to meet the needs of small- to medium-sized labs that want to share data and code among users with varying technical sophistication. 

## Features and choices

- Fully docker-ized deployment. All you need for installation is Docker, SSL certificates, and drivers for your GPU.
- An authentication system supervised by the `admin` user allows prospective new users to apply for access and choose their own password.
- Users are given access to the Jupyterhub container but do not have login privliges on the host system.
- To allow for easy reproducibility, Jupyter kernels can be run in user-managed conda environments, or in user-managed Docker containers (using the excellent Dockernel package).
- Kernel containers are sibling-containers, in a Docker-out-of-Docker (DooD) configuration.
- Full support for NVIDIA GPUs in compute kernels (including Docker-ized kernels).
- By default users have read-only access to all other users' home directories.
- A shared directory /home/shared allows read-write access to files for collaboration.
- A read-only subdirectory /home/shared/readonly allows sharing of source data that should not be modified.

## Security issues

Labnotebook is designed to share a system among a small trusted group, and is intended to allow essentially arbitrary code execution by those trusted users. The system runs in a Docker container, so those users are insulated from unintentionally making changes to the host. However, they are given access to the Docker socket in order to run kernel containers which creates a risk of privlige escalation. 

You should configure SSL certificates to allow users to authenticate the server. (These are mounted in to the Docker container to be used by the Jupyterhub server.) If your machine is visible on the public internet then Let's Encrypt is an excellent way to do generate them. If you are behind an institutional firewall you will need to rely on certificates issued by your institution. Running without SSL is possible, but not recommended.

## Installation

- Install Docker
- Install NVIDIA drivers and nvidia-container-toolkit
- Run build.sh to create the container (and container volumes to store data)
- Run run.sh to run the service

To Do:

- [x] Persist user database in Volumes
- [x] Volume vs bind mount for home directories? (Prob volume bc users won't have access on the native host)
- [x] Script for user setup on creation
- [x] Upgrade Jupyterhub to 4.0
- [ ] Install and integrate matlab [Should MATLAB kernel be in a sub-Docker?]
- [x] Test Dockernel
- [x] Dockernel GPU support: need to fork the repo to add gpu support in /cli/install.py
- [x] SSL encryption: Working!
- [x] Test GPU support: Working! Requires nvidia-container-toolkit installed on host. Base image includes nvidia-smi to verify.
- [x] Install acl (for setfacl) to maintain permission in /home/share directory
- [ ] Symlink /home/shared from /home/$USER/shared
- [ ] Create /home/shared/readonly, set permissions with acl
- [ ] Clean up kernel locations, sample build files
- [ ] Good way to get data in and stored
- [ ] Documentation 
