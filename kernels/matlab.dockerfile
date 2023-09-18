# Use the mathworks/matlab base image, matlabengine not yet compatible with R2023b
FROM mathworks/matlab-deep-learning:r2023a

USER root
WORKDIR /

# Need this env variable for matlabengine
ENV LD_LIBRARY_PATH=/opt/matlab/R2023a/bin/glnxa64:$LD_LIBRARY_PATH

RUN pip install matlabengine==9.14.3
RUN pip install matlab_kernel==0.17.1

# Must use a license file, LNU licensing will not work
COPY ./matlab_license.lic /matlab_license.lic
ENV MLM_LICENSE_FILE=/matlab_license.lic

EXPOSE 8888

CMD python -m matlab_kernel -f $DOCKERNEL_CONNECTION_FILE
