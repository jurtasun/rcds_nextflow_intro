# Use official devcontainer base image (Ubuntu)
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jre \
    curl \
    groovy \
    && rm -rf /var/lib/apt/lists/*

# Install Nextflow
RUN curl -s https://get.nextflow.io | bash \
    && mv nextflow /usr/local/bin/ \
    && chmod +x /usr/local/bin/nextflow \
    && chown vscode:vscode /usr/local/bin/nextflow

# Verify installation
RUN groovy --version && nextflow -version
