#!/bin/bash

# SecureBank Security Audit Script
# Purpose: Daily security audit report

DATE=$(date '+%Y-%m-%d %H:%M:%S')
REPORT="/home/lab-server/lab-projects/scripting/security-audit.log"

echo "================================" >> $REPORT
echo "SecureBank Security Audit Report" >> $REPORT
echo "Date: $DATE" >> $REPORT
echo "================================" >> $REPORT

# Check 1 - Failed Login Attempts
echo "" >> $REPORT
echo "FAILED LOGIN ATTEMPTS:" >> $REPORT
FAILED=$(grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l)
echo "Total: $FAILED attempts" >> $REPORT

if [ $FAILED -gt 10 ]; then
    echo "STATUS: WARNING - High number of failed logins" >> $REPORT
else
    echo "STATUS: OK" >> $REPORT
fi

# Check 2 - Open Ports
echo "" >> $REPORT
echo "OPEN PORTS:" >> $REPORT
ss -tulpn | grep LISTEN >> $REPORT

# Check 3 - Firewall Status
echo "" >> $REPORT
echo "FIREWALL STATUS:" >> $REPORT
sudo ufw status >> $REPORT

# Check 4 - Users with sudo access
echo "" >> $REPORT
echo "USERS WITH SUDO ACCESS:" >> $REPORT
grep -Po '^sudo.+:\K.*$' /etc/group >> $REPORT

# Check 5 - Last Logins
echo "" >> $REPORT
echo "LAST 5 LOGINS:" >> $REPORT
last -n 5 >> $REPORT

echo "" >> $REPORT
echo "END OF AUDIT REPORT" >> $REPORT
echo "================================" >> $REPORT

echo "Audit complete. Report saved to $REPORT"

