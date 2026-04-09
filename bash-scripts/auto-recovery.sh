#!/bin/bash

# SecureBank Auto Recovery Script
# Purpose: Monitor and restart critical services

# Critical services to monitor
SERVICES=("nginx" "ssh")

# Log file
LOG_FILE="/var/log/bank-recovery.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Starting service check..." >> $LOG_FILE

for SERVICE in "${SERVICES[@]}"; do
    if systemctl is-active --quiet $SERVICE; then
        echo "[$DATE] OK: $SERVICE is running" >> $LOG_FILE
    else
        echo "[$DATE] ALERT: $SERVICE is down. Restarting..." >> $LOG_FILE
        sudo systemctl restart $SERVICE
        
        if systemctl is-active --quiet $SERVICE; then
            echo "[$DATE] RECOVERED: $SERVICE restarted successfully" >> $LOG_FILE
        else
            echo "[$DATE] CRITICAL: $SERVICE failed to restart!" >> $LOG_FILE
        fi
    fi
done
