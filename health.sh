#!/bin/bash

# System Health Check Script

# Function to check disk usage
check_disk_usage() {
    echo "Disk Usage:"
    df -h
}

# Function to check memory usage
check_memory_usage() {
    echo "Memory Usage:"
    free -h
}

# Function to check running services
check_running_services() {
    echo "Running Services:"
    systemctl list-units --type=service --state=running
}

# Function to check recent system updates
check_system_updates() {
    echo "Recent System Updates:"
    tail -n 20 /var/log/apt/history.log
}

echo "System Health Check Report:"
echo "------------check_disk_usage----------------"
check_disk_usage
echo
echo "------------check_memory_usage----------------"
check_memory_usage
echo
echo "------------check_running_services----------------"
check_running_services
echo
echo "------------check_system_updates----------------"
check_system_updates
echo "----------------------------"
echo "System health check completed."