FROM tensorflow/tensorflow:2.13.0-gpu

# These lines are necessary for an iPython kernel
RUN pip install --upgrade pip ipython ipykernel
CMD python -m ipykernel_launcher -f $DOCKERNEL_CONNECTION_FILE

