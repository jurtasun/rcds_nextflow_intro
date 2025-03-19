# Use an Ubuntu base image
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jre \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Nextflow
RUN curl -s https://get.nextflow.io | bash \
    && mv nextflow /usr/local/bin/

# Set Nextflow to be executable
RUN chmod +x /usr/local/bin/nextflow

# Verify installation
RUN nextflow -version

