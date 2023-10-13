FROM continuumio/miniconda3:4.12.0

WORKDIR /skycamp-tutorial

ADD ./requirements.txt /skycamp-tutorial/requirements.txt

# Install tutorial dependencies
RUN pip install -r requirements.txt

# Install SkyPilot + dependencies
RUN conda install -c conda-forge google-cloud-sdk && \
    gcloud components install gke-gcloud-auth-plugin && \
    apt update -y && \
    apt install rsync nano vim -y && \
    pip install skypilot[gcp,kubernetes] && \
    rm -rf /var/lib/apt/lists/*

# Copy credentials.
# UPDATE - no longer required. Instead mount the .aws and .config dirs to /credentials and it will be copied over.
# COPY src/.aws /root/.aws
# COPY src/.config/gcloud /root/.config/gcloud

# Exclude usage logging message
RUN mkdir -p /root/.sky && touch /root/.sky/privacy_policy

# Add files which may change frequently
COPY . /skycamp-tutorial

# Set bash as default shell
ENV SHELL /bin/bash

# Setup gcp credentials
ENV GOOGLE_APPLICATION_CREDENTIALS=/root/gcp-key.json
ENV GCP_PROJECT_ID=skycamp-skypilot-fastchat

CMD ["/bin/bash", "-c", "cp -a /credentials/. /root/;gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS;gcloud config set project $GCP_PROJECT_ID;sky show-gpus;jupyter lab --no-browser --ip '*' --allow-root --notebook-dir=/skycamp-tutorial --NotebookApp.token='SkyCamp2023'"]
