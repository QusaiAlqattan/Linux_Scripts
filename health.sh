#!/bin/bash

# System Health Check Script

# Function to generate recommendations for disk usage
generate_disk_usage_recommendations() {
    disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$disk_usage" -ge 80 ]; then
        echo "Warning: Disk usage is above 80%. Consider cleaning up disk space."
    else
        echo "Disk usage is within normal limits."
    fi
}

# Function to check disk usage
check_disk_usage() {
    df -h
}

# Function to generate recommendations for memory usage
generate_memory_usage_recommendations() {
    total_memory=$(free | grep Mem | awk '{print $2}')
    free_memory=$(free | grep Mem | awk '{print $4}')
    memory_free_percent=$(( 100 * free_memory / total_memory ))
    if [ "$memory_free_percent" -lt 20 ]; then
        echo "Warning: Free memory is below 20%. Consider adding more memory or closing unnecessary applications."
    else
        echo "Memory usage is within normal limits (less than 20%)."
    fi
}

# Function to check memory usage
check_memory_usage() {
    free -h
}

# Function to generate recommendations for running services
generate_running_services_recommendations() {
    critical_services=("ssh" "nginx" "mysql")
    for service in "${critical_services[@]}"; do
        if ! systemctl is-active --quiet "$service"; then
            echo "Warning: $service service is not running. Consider starting it if needed."
        fi
    done
}

# Function to check running services
check_running_services() {
    systemctl list-units --type=service --state=running
}

# Function to generate recommendations for system updates
generate_system_updates_recommendations() {
    updates_available=$(apt list --upgradable 2>/dev/null | wc -l)
    if [ "$updates_available" -gt 1 ]; then
        echo "There are $((updates_available - 1)) updates available. Consider updating your system."
    else
        echo "Your system is up to date."
    fi
}

# Function to check recent system updates
check_system_updates() {
    tail -n 20 /var/log/apt/history.log
}

# Function to display the menu
show_menu() {
    echo "Select the checks you want to perform:"
    echo "1. Disk Usage"
    echo "2. Memory Usage"
    echo "3. Running Services"
    echo "4. Recent System Updates"
    echo "5. All Checks"
    echo "6. Exit"
}

# Function to perform selected checks
perform_checks() {
    # Perform detailed checks first if enabled
    for check in "${selected_checks[@]}"; do
        case $check in
            1)
                echo "------------check_disk_usage----------------"
                if [ "$detailed_check" -eq 1 ]; then
                    check_disk_usage
                fi
                echo "Recommendations:"
                generate_disk_usage_recommendations
                echo
                ;;
            2)
                echo "------------check_memory_usage----------------"
                if [ "$detailed_check" -eq 1 ]; then
                    check_memory_usage
                fi
                echo "Recommendations:"
                generate_memory_usage_recommendations
                echo
                ;;
            3)
                echo "------------check_running_services----------------"
                if [ "$detailed_check" -eq 1 ]; then
                    check_running_services
                fi
                echo "Recommendations:"
                generate_running_services_recommendations
                echo
                ;;
            4)
                echo "------------check_system_updates----------------"
                if [ "$detailed_check" -eq 1 ]; then
                    check_system_updates
                fi
                echo "Recommendations:"
                generate_system_updates_recommendations
                echo
                ;;
            5)
                echo "------------check_disk_usage----------------"
                if [ "$detailed_check" -eq 1 ]; then
                    check_disk_usage
                fi
                echo "Recommendations:"
                generate_disk_usage_recommendations
                echo
                echo "------------check_memory_usage----------------"
                if [ "$detailed_check" -eq 1 ]; then
                    check_memory_usage
                fi
                echo "Recommendations:"
                generate_memory_usage_recommendations
                echo
                echo "------------check_running_services----------------"
                if [ "$detailed_check" -eq 1 ]; then
                    check_running_services
                fi
                echo "Recommendations:"
                generate_running_services_recommendations
                echo
                echo "------------check_system_updates----------------"
                if [ "$detailed_check" -eq 1 ]; then
                    check_system_updates
                fi
                echo "Recommendations:"
                generate_system_updates_recommendations
                echo
                ;;
            6)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid option."
                ;;
        esac
    done
    echo "----------------------------"
    echo "System health check completed."
}

# Prompt user for detailed or simple check
read -p "Do you want a detailed check with recommendations? (yes/no): " detailed_choice
if [[ "$detailed_choice" =~ ^[Yy][Ee][Ss]|[Yy]$ ]]; then
    detailed_check=1
else
    detailed_check=0
fi

selected_checks=()
while true; do
    show_menu
    read -p "Enter your choice (1-6): " choice
    if [[ $choice -eq 6 ]]; then
        break
    elif [[ $choice -ge 1 && $choice -le 5 ]]; then
        # Check if the choice is already in selected_checks
        if [[ ! " ${selected_checks[@]} " =~ " $choice " ]]; then
            selected_checks+=($choice)
        else
            echo "Option $choice is already selected. Please choose a different option."
        fi
    else
        echo "Invalid choice. Please select a number between 1 and 6."
    fi
done

perform_checks