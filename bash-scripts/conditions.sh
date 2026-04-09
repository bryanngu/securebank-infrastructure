#!/bin/bash

# Conditions Example 
echo "=== Service Health Check ==="
read SERVICE

# Check if service is running
if systemctl is-active --quiet $SERVICE; then
    echo "✓ $SERVICE is running"
else
    echo "✗ $SERVICE is NOT running"
    echo "Attempting to start $SERVICE..."
    sudo systemctl start $SERVICE

    #Check again after trying to start
    if systemctl is-active --quiet $SERVICE; then
        echo "✓ $SERVICE started successfully"
    else 
        echo "✗ Failed to start $SERVICE"
        echo "Please check manually"
    fi
fi
