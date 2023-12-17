#!/bin/bash

# Define thresholds for system metrics
CPU_THRESHOLD=80
MEMORY_THRESHOLD=5
DISK_THRESHOLD=80

# Define services to monitor
SERVICES=("httpd" "mysql" "ssh")

# Define log files to monitor
LOG_FILES=("/var/log/apache2/error.log" "/var/log/mysql/error.log" "/var/log/auth.log")

# Function to check system metrics
check_system_metrics() {
    # Get CPU usage percentage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    
    # Get memory usage percentage
    memory_usage=$(free | awk '/Mem/ {printf "%.2f", $3/$2 * 100}')
    
    # Get disk usage percentage
    disk_usage=$(df -h | awk '$NF == "/" {print $5}' | sed 's/%//')
    
    # Check CPU usage
    if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
        echo "High CPU usage: $cpu_usage%" >> metrics.txt
    fi
    
    # Check memory usage
    if (( $(echo "$memory_usage > $MEMORY_THRESHOLD" | bc -l) )); then
        echo "High memory usage: $memory_usage%" >> metrics.txt
    fi
    
    # Check disk usage
    if (( $(echo "$disk_usage > $DISK_THRESHOLD" | bc -l) )); then
        echo "High disk usage: $disk_usage%" >> metrics.txt
    fi
}

# Function to check services
check_services() {
    for service in "${SERVICES[@]}"; do
        if ! pgrep -x "$service" >/dev/null; then
            echo "Service $service is not running" >> metrics.txt
        fi
    done
}

# Function to check log files
check_log_files() {
    for log_file in "${LOG_FILES[@]}"; do
        if [[ ! -f "$log_file" ]]; then
            echo "Log file $log_file does not exist" >> metrics.txt
        elif [[ ! -r "$log_file" ]]; then
            echo "Log file $log_file is not readable" >> metrics.txt
        fi
    done
}

# Main function
main() {
    # Clear previous metrics
    > metrics.txt
    
    # Check system metrics
    check_system_metrics
    
    # Check services
    check_services
    
    # Check log files
    check_log_files
}

# Run the main function
main

