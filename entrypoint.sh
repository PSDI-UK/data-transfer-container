#!/bin/bash

# Run the configuration scripts
/app/configure-s3cmd.sh
/app/configure-rclone.sh

# Start a shell or keep the container running
exec "$@"
