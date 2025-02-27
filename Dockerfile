
# 'build' target: Create image with rclone, s3cmd, cyberduck CLI, AWS CLI and restic installed

# Use Ubuntu as the base image
FROM ubuntu:latest

# Define non-root user variables - specified at build time.
# These define the user owning the app and the default user in the
# container when it is run
# NOTE: This should not be 1000 otherwise the creation of the user
# below will fail (since 1000 is already a user in Ubuntu)
ARG UID=1002
ARG GID=1002
ARG USERNAME=appuser

# Create the non-root user
RUN groupadd -g $GID $USERNAME && \
    useradd -m -u $UID -g $GID -s /bin/bash $USERNAME

# rclone version to use (see https://rclone.org/downloads/)
ENV INSTALL_RCLONE_VERSION='rclone-v1.68.2-linux-amd64'
# aws cli version to use (see https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
ENV INSTALL_AWSCLI_VERSION='awscli-exe-linux-x86_64'
# Set the default rclone config path
ENV RCLONE_CONFIG=/app/.config/rclone/rclone.conf
# Set the default s3cmd config path
ENV S3CMD_CONFIG=/app/.s3cfg
# Set the environment variables for AWS CLI
ENV AWS_SHARED_CREDENTIALS_FILE=/app/.aws/credentials

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
RUN curl -O https://downloads.rclone.org/v1.68.2/${INSTALL_RCLONE_VERSION}.zip && \
    unzip ${INSTALL_RCLONE_VERSION}.zip && \
    cp ${INSTALL_RCLONE_VERSION}/rclone /usr/bin/ && \
    chmod 755 /usr/bin/rclone && \
    mkdir -p /usr/local/share/man/man1 && \
    cp ${INSTALL_RCLONE_VERSION}/rclone.1 /usr/local/share/man/man1/ && \
    mandb && \
    rm -rf ${INSTALL_RCLONE_VERSION} ${INSTALL_RCLONE_VERSION}.zip

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

# Dynamically configuring s3cmd/rclone inside the Docker container by passing environment variables and generating the .s3cfg file at runtime.

# Copy configuration scripts for s3cmd and rclone into the image
COPY configure-s3cmd.sh /app/configure-s3cmd.sh
COPY configure-rclone.sh /app/configure-rclone.sh
COPY configure-awscli.sh /app/configure-awscli.sh
# Give all users execute permission for configuration scripts
RUN chmod a+x /app/configure-s3cmd.sh /app/configure-rclone.sh /app/configure-awscli.sh

# Copy the s3.cyberduckprofile to the Cyberduck profiles directory
RUN mkdir -p /app/.duck/profiles
COPY S3-deprecatedprofile.cyberduckprofile /app/.duck/profiles/S3-deprecatedprofile.cyberduckprofile

# Copy entrypoint script for the container
COPY entrypoint.sh /app/entrypoint.sh
# Give all users execute permission for entrypoint script
RUN chmod a+x /app/entrypoint.sh

# Ensure non-root user owns /app
RUN chown -R $USERNAME:$USERNAME /app
# But allow any user in the container to do access the /app directory.
# This is required so that any (non-root) user ID can execute the above entrypoint
# and configuration scripts (which create the configuration files for the data
# transfer software when the container is started)
RUN chmod a+rwx /app

# Switch to non-root user
USER $USERNAME

# Set entrypoint for runtime configuration
ENTRYPOINT ["/app/entrypoint.sh"]
