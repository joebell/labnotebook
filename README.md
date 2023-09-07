# labnotebook
A jupyterhub system designed to allow reproducible research with docker-ized kernels; all in a docker container.

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
- [ ] Clean up shared directory, kernel locations, default permissions
- [ ] Good way to get data in and stored
- [ ] Documentation 
