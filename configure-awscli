#!/bin/bash

# Check if required environment variables are set
if [ -z "$ACCESS_KEY" ] || [ -z "$SECRET_KEY" ]; then
    echo "Error: ACCESS_KEY and SECRET_KEY environment variables must be set!"
    exit 1
fi

# Define the constant endpoint URL
AWS_ENDPOINT_URL="https://s3.echo.stfc.ac.uk"

# Configure AWS CLI
mkdir -p ~/.aws

# Write credentials file
cat > ~/.aws/credentials <<EOL
[default]
aws_access_key_id = $ACCESS_KEY
aws_secret_access_key = $SECRET_KEY
EOL

echo "AWS CLI configured successfully."