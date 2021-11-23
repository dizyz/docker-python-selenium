# Image for a Python 3 development environment
FROM python:3.9-slim

# Add any tools that are needed beyond Python 3.9
RUN apt-get update \
    && apt-get install -y sudo git zip tree curl wget jq \
    && apt-get autoremove -y \
    && apt-get clean -y

# Install IBM Cloud CLI
RUN curl -fsSL https://clis.cloud.ibm.com/install/linux | sh

# Set up the Python development environment
WORKDIR /app
COPY requirements.txt .
RUN apt-get install -y gcc libpq-dev \
    && pip install -U pip wheel \
    && pip install -r requirements.txt
EXPOSE 8080

# Create a user for development
ARG USERNAME=devops
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user with passwordless sudo privileges
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash \
    && usermod -aG sudo $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Become a regular user
USER $USERNAME