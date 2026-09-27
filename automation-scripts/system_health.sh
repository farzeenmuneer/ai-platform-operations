#!/bin/bash
# ============================================
# Native Linux Daemon Script
# System Health & Maintenance Tracker
# ============================================

LOG_FILE="/var/log/ai_engine_sre.log"
THRESHOLD=85

touch $LOG_FILE

echo "[$(date)] Launching Automated SRE Infrastructure Health Scans..." >> $LOG_FILE


# ============================================
# 1. Linux Administration: Disk Usage Check
# ============================================
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

if [ "$DISK_USAGE" -gt "$THRESHOLD" ]; then
    echo "[ALERT] Storage capacity exceeded at ${DISK_USAGE}%" >> $LOG_FILE
    echo "Initiating systematic cleanup of historical logs..." >> $LOG_FILE
    
    sudo find /var/log -type f -name "*.log" -size +10M -exec truncate -s 0 {} \;
    
    echo "[INFO] Log rotation completed." >> $LOG_FILE
else
    echo "[INFO] Disk usage: ${DISK_USAGE}% (Healthy)" >> $LOG_FILE
fi

# ============================================
# 2. Database Fundamentals: PostgreSQL Check
# ============================================
pg_isready -h localhost -p 5432 -U postgres > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "[INFO] Database connectivity: HEALTHY" >> $LOG_FILE
else
    echo "[CRITICAL] Database connection failure!" >> $LOG_FILE
    echo "Executing background restart..." >> $LOG_FILE
    sudo systemctl restart postgresql 2>/dev/null || echo "[INFO] PostgreSQL not installed." >> $LOG_FILE
fi

# ============================================
# 3. System Monitoring: CPU + Memory
# ============================================
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
MEM_USAGE=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')

echo "[INFO] CPU: ${CPU_USAGE}% | Memory: ${MEM_USAGE}%" >> $LOG_FILE
echo "[$(date)] Health scan completed." >> $LOG_FILE
echo "----------------------------------------" >> $LOG_FILE