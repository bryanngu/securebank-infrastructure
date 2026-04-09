#!/bin/bash

# SecureBank Server Health Check Script
# Author: Bryan
# Purpose: Daily health check of bank servers

# Variables
BANK_NAME="SecureBank"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="/var/log/bank-health.log"

# Function to print section header
print_header() {
    echo "================================"
    echo "  $1"
    echo "================================"
}

# Start Report
print_header "$BANK_NAME Health Check Report"
echo "Date: $DATE"
echo ""

# Check 1 - System Info
print_header "System Information"
echo "Server: $(hostname)"
echo "IP: $(hostname -I)"
echo "Uptime: $(uptime -p)"
echo ""

# Check 2 - CPU and Memory
print_header "Resource Usage"
echo "CPU Load: $(top -bn1 | grep 'Cpu(s)' | awk '{print $2}')%"
echo "Memory Usage:"
free -h | grep Mem
echo ""

# Check 3 - Disk Space
print_header "Disk Space"
df -h | grep -v tmpfs
echo ""

# Check 4 - Critical Services
print_header "Service Status"
SERVICES=("nginx" "ssh")
for SERVICE in "${SERVICES[@]}"; do
    if systemctl is-active --quiet $SERVICE; then
        echo "✓ $SERVICE is running"
    else
        echo "✗ $SERVICE is NOT running - ALERT!"
    fi
done
echo ""

# Check 5 - Failed Login Attempts
print_header "Security Check"
FAILED=$(grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l)
echo "Failed login attempts: $FAILED"
echo ""

print_header "End of Report"
echo "Report saved to: $LOG_FILE"

