ARG build=latest-gpu

FROM tensorflow/tensorflow:$build

# Signal user that he has to mount directories
VOLUME /model/input
VOLUME /model/output

# Set directory inside container
WORKDIR /model

# Install dependencies
COPY requirements-docker.txt requirements.txt
RUN pip install -r requirements.txt

# Copy code
COPY code/ ./code/

# Specify command to run on container start
CMD ["python", "code/script.py"]
