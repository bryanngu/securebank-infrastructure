#!/bin/bash

#variables Example Script

#Defining variables
SERVER_NAME="lab-server"
ADMIN_NAME="Bryan"
MAX_CONNECTIONS=100

#Using Variables
echo "Server: $SERVER_NAME"
echo "Admin: $ADMIN_NAME"
echo "Max Connections: $MAX_CONNECTIONS"

#Variables in sentences
echo "$ADMIN_NAME manages $SERVER_NAME"

#Variables from command output
CURRENT_IP=$(hostname -I)
echo "Server IP: $CURRENT_IP"

#Math with variables
USED_CONNECTIONS=45
FREE_CONNECTIONS=$((MAX_CONNECTIONS - USED_CONNECTIONS))
echo "Free Connections: $FREE_CONNECTIONS"

