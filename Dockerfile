FROM python:3.11.4-slim-buster

# Install required system packages
RUN apt-get update && \
    apt-get install -y \
    build-essential && \
    apt-get clean

# Set the working directory
WORKDIR /work
