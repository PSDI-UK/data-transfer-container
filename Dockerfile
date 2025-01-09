# Use Ubuntu as the base image
FROM ubuntu:latest

# Update package lists and install necessary dependencies
RUN apt-get update && apt-get install -y \
    s3cmd \
    curl \
    unzip \
    python3-pip \
    man-db
    
# Set up a temporary directory for installations
WORKDIR /tmp

# Install required software...

# Install rclone
RUN curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip && \
    unzip rclone-current-linux-amd64.zip
WORKDIR /tmp/rclone-*-linux-amd64
RUN cp rclone /usr/bin/ && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone && \
    mkdir -p /usr/local/share/man/man1 && \
    cp rclone.1 /usr/local/share/man/man1/ && \
    mandb
WORKDIR /tmp

# Clean up
RUN rm -rf rclone-*-linux-amd64 rclone-current-linux-amd64.zip

# Set the final working directory
WORKDIR /app

# Dynamically configuring s3cmd/rclone inside the Docker container by passing environment variables and generating the .s3cfg file at runtime. Need to check with Tom regarding this

# Copy configuration scripts for s3cmd and rclone into the image
COPY configure-s3cmd.sh /app/configure-s3cmd.sh
COPY configure-rclone.sh /app/configure-rclone.sh
RUN chmod +x /app/configure-s3cmd.sh /app/configure-rclone.sh

# Copy entrypoint script for the container
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Set entrypoint for runtime configuration
ENTRYPOINT ["/app/entrypoint.sh"]

# Amali to provide shell commands here after 'RUN'. Note that you can't change directory
# with 'cd', rather you should use 'WORKDIR' instead. Below is an example set of
# instructions to install 'wget', change directory to '/an/example/dir', invoke a shell
# script 'example.sh', and copy a file from the repo into the container:
#    RUN apt-get install wget
#    WORKDIR /an/example/dir
#    RUN sh example.sh
#    COPY file.txt /target/dir/for/file/
