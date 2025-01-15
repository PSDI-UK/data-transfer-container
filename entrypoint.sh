#!/bin/bash

# Validate required environment variables
if [ -z "$ACCESS_KEY" ]; then
    echo "Error: ACCESS_KEY environment variable is not set." >&2
    exit 1
fi

if [ -z "$SECRET_KEY" ]; then
    echo "Error: SECRET_KEY environment variable is not set." >&2
    exit 1
fi

# Run the configuration scripts
if ! /app/configure-s3cmd.sh; then
    echo "Error: configure-s3cmd.sh failed." >&2
    exit 1
fi

if ! /app/configure-rclone.sh; then
    echo "Error: configure-rclone.sh failed." >&2
    exit 1
fi

if ! /app/configure-awscli.sh; then
    echo "Error: configure-awscli.sh failed." >&2
    exit 1
fi

echo "All configuration scripts executed successfully."

# Start a shell or keep the container running
exec "$@"