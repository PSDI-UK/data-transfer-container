#!/bin/bash

# Check for required environment variables
if [ -z "$ACCESS_KEY" ] || [ -z "$SECRET_KEY" ]; then
    echo "Error: ACCESS_KEY and SECRET_KEY environment variables must be set!"
    exit 1
fi

# Create the rclone configuration directory if it doesn't exist
mkdir -p /app/.config/rclone

# Dynamically create the rclone configuration file with hard-coded values
cat > /app/.config/rclone/rclone.conf <<EOL
[ceph-remote]
type = s3
provider = Ceph
access_key_id = ${ACCESS_KEY}
secret_access_key = ${SECRET_KEY}
endpoint = https://s3.echo.stfc.ac.uk
EOL

echo "rclone configuration file created successfully at /app/.config/rclone/rclone.conf"
