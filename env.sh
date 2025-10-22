#!/bin/bash

# Script to load AWS environment variables for Terraform
# Usage: source ./env.sh

if [ -f ".env" ]; then
    echo "Loading environment variables from .env file..."
    set -a
    source .env
    set +a
    echo "Environment variables loaded successfully."
else
    echo "Error: .env file not found. Please copy .env.template to .env and fill in your credentials."
    exit 1
fi