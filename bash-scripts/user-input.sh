#!/bin/bash

#User Input Example
echo "==================================="
echo "    Server Management Tool"
echo "==================================="
echo ""

#Ask for input
echo "what is your name?"
read ADMIN_NAME

echo "which service do you want to check?"
read SERVICE_NAME

echo""
echo "Hello $ADMIN_NAME!"
echo "Checking status of $SERVICE_NAME..."
echo ""

#Use the input in a real command
sudo systemctl status $SERVICE_NAME

