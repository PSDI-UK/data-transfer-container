
# 'build' target: Create image with rclone, s3cmd, cyberduck CLI, AWS CLI and restic installed

# Use Ubuntu as the base image
FROM ubuntu:latest AS build

# rclone version to use (see https://rclone.org/downloads/)
ENV INSTALL_RCLONE_VERSION='rclone-v1.68.2-linux-amd64'
# aws cli version to use (see https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
ENV INSTALL_AWSCLI_VERSION='awscli-exe-linux-x86_64'

# Update package lists and install necessary dependencies
RUN apt-get update && apt-get install -y \
    s3cmd \
    restic \
    curl \
    unzip \
    fuse \
    python3-pip \
    man-db \
    gnupg \
    ca-certificates \
    less
    
# Set up a temporary directory for installations
WORKDIR /tmp

# Install required software...

# Install rclone
RUN curl -O https://downloads.rclone.org/v1.68.2/${INSTALL_RCLONE_VERSION}.zip
RUN unzip ${INSTALL_RCLONE_VERSION}.zip
WORKDIR /tmp/${INSTALL_RCLONE_VERSION}
RUN cp rclone /usr/bin/
RUN chown root:root /usr/bin/rclone
RUN chmod 755 /usr/bin/rclone
RUN mkdir -p /usr/local/share/man/man1
RUN cp rclone.1 /usr/local/share/man/man1/
RUN mandb
WORKDIR /tmp

# Clean up
RUN rm -rf ${INSTALL_RCLONE_VERSION} ${INSTALL_RCLONE_VERSION}.zip

# Install Cyberduck CLI (Duck)
RUN echo "deb https://s3.amazonaws.com/repo.deb.cyberduck.io stable main" | tee /etc/apt/sources.list.d/cyberduck.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FE7097963FEFBE72 && \
    apt-get update && \
    apt-get install -y duck

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/${INSTALL_AWSCLI_VERSION}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws
    
# Set the final working directory
WORKDIR /app



# default target: Add config files to 'build' target

FROM build

# Dynamically configuring s3cmd/rclone inside the Docker container by passing environment variables and generating the .s3cfg file at runtime. Need to check with Tom regarding this

# Copy configuration scripts for s3cmd and rclone into the image
COPY configure-s3cmd.sh /app/configure-s3cmd.sh
COPY configure-rclone.sh /app/configure-rclone.sh
COPY configure-awscli.sh /app/configure-awscli.sh
RUN chmod +x /app/configure-s3cmd.sh /app/configure-rclone.sh /app/configure-awscli.sh

# Copy entrypoint script for the container
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Set entrypoint for runtime configuration
ENTRYPOINT ["/app/entrypoint.sh"]
