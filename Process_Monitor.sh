#!/bin/bash

# Configuration File
CONFIG_FILE="config.cfg"

# Default Configuration Values
DEFAULT_INTERVAL=5
DEFAULT_CPU_THRESHOLD=80.0
DEFAULT_MEM_THRESHOLD=80.0
DEFAULT_LOG_FILE="process_monitor.log"
DEFAULT_EMAIL="your-email@example.com"

# Load Configuration from File
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        . "$CONFIG_FILE"
    else
        INTERVAL=${DEFAULT_INTERVAL}
        CPU_THRESHOLD=${DEFAULT_CPU_THRESHOLD}
        MEM_THRESHOLD=${DEFAULT_MEM_THRESHOLD}
        LOG_FILE=${DEFAULT_LOG_FILE}
        EMAIL=${DEFAULT_EMAIL}
    fi
}

# Function to write to log file
log_activity() 
{
    local message=$1
    echo $LOG_FILE
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"
    #cat $LOG_FILE
}

# Function to list all processes
list_processes() {
    printf "%-10s %-25s %-10s %-10s %-10s\n" "PID" "NAME" "USER" "CPU(%)" "MEM(%)"
    ps -eo pid,comm,user,%cpu,%mem --sort=-%cpu | awk 'NR==1 {next} {printf "%-10s %-25s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5}'
}

# Function to display detailed information about a specific process
process_info() {
    local pid=$1
    if [[ -z "$pid" || ! "$pid" =~ ^[0-9]+$ ]]; then
        echo "Invalid PID."
        return 1
    fi
    ps -p "$pid" -o pid,ppid,comm,user,%cpu,%mem,etime
}

# Function to terminate a specific process
kill_process() {
    local pid=$1
    if [[ -z "$pid" || ! "$pid" =~ ^[0-9]+$ ]]; then
        echo "Invalid PID."
        return 1
    fi
    if kill -0 "$pid" 2>/dev/null; then
        kill "$pid"
        log_activity "Terminated process with PID $pid."
        echo "Process $pid terminated."
    else
        echo "No such process with PID $pid."
    fi
}

# Function to display overall system process statistics
system_statistics() {
    local total_processes
    total_processes=$(ps -e | wc -l)
    local memory_usage
    memory_usage=$(free -m | awk '/^Mem:/ {print $3 " MB"}')
    local cpu_load
    cpu_load=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf("%.2f%%", 100 - $1)}')

    echo "Total number of processes: $total_processes"
    echo "Memory usage: $memory_usage"
    echo "CPU load: $cpu_load"
}

# Function to check and alert on resource usage
check_resources() {
    local threshold=$1
    local resource=$2
    local subject
    local body

    if [[ "$resource" != "cpu" && "$resource" != "mem" ]]; then
        echo "Invalid resource type. Use 'cpu' or 'mem'."
        return 1
    fi

    if [[ -z "$threshold" ]]; then
        echo "Threshold not provided."
        return 1
    fi

    local high_usage
    high_usage=$(ps -eo pid,comm,user,%cpu,%mem --sort=-%cpu | awk -v threshold="$threshold" -v resource="$resource" '
    resource == "cpu" {if ($4 >= threshold) printf "%-10s %-25s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5}
    resource == "mem" {if ($5 >= threshold) printf "%-10s %-25s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5}
    ')

    if [[ -n "$high_usage" ]]; then
        subject="Alert: High ${resource^} Usage Detected"
        body="The following processes have high ${resource^} usage:\n\n$high_usage"
        send_email_alert "$subject" "$body"
        log_activity "$body"
        echo "$body"
    fi
}

# Function to start monitoring in real-time
real_time_monitoring() 
{
    x=1
    echo "Real-time monitoring started. Press Ctrl+C to stop."
    while [ "$x" -lt 5 ]; do
        list_processes
        system_statistics
        check_resources "$CPU_THRESHOLD" "cpu"
        check_resources "$MEM_THRESHOLD" "mem"
        sleep "$INTERVAL"
        x=$((x + 1)) 
        clear
    done
}

# Function to search processes based on criteria
search_processes() {
    echo "Enter search criteria (name, user, cpu, mem):"
    read criteria
    echo "Enter value:"
    read value

    case "$criteria" in
        name)
            search_by_name "$value"
            ;;
        user)
            search_by_user "$value"
            ;;
        cpu|mem)
            search_by_resource "$criteria" "$value"
            ;;
        *)
            echo "Invalid criteria. Use 'name', 'user', 'cpu', or 'mem'."
            ;;
    esac
}

# Function to search by name
search_by_name() {
    local name=$1
    printf "%-10s %-25s %-10s %-10s %-10s\n" "PID" "NAME" "USER" "CPU(%)" "MEM(%)"
    ps -eo pid,comm,user,%cpu,%mem --sort=-%cpu | grep -i "$name" | awk '{printf "%-10s %-25s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5}'
}

# Function to search by user
search_by_user() {
    local user=$1
    printf "%-10s %-25s %-10s %-10s %-10s\n" "PID" "NAME" "USER" "CPU(%)" "MEM(%)"
    ps -eo pid,comm,user,%cpu,%mem --sort=-%cpu | awk -v u="$user" '$3 == u {printf "%-10s %-25s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5}'
}

# Function to search by resource usage
search_by_resource() {
    local resource=$1
    local threshold=$2

    if [[ "$resource" != "cpu" && "$resource" != "mem" ]]; then
        echo "Invalid resource type. Use 'cpu' or 'mem'."
        return 1
    fi

    if [[ -z "$threshold" ]]; then
        echo "Threshold not provided."
        return 1
    fi

    printf "%-10s %-25s %-10s %-10s %-10s\n" "PID" "NAME" "USER" "CPU(%)" "MEM(%)"
    ps -eo pid,comm,user,%cpu,%mem --sort=-%cpu | awk -v threshold="$threshold" -v resource="$resource" '
    resource == "cpu" {if ($4 >= threshold) printf "%-10s %-25s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5}
    resource == "mem" {if ($5 >= threshold) printf "%-10s %-25s %-10s %-10s %-10s\n", $1, $2, $3, $4, $5}
    '
}

# Function to display menu
display_menu() {
    echo "Menu:"
    echo "1. List Processes"
    echo "2. Process Information"
    echo "3. Kill a Process"
    echo "4. System Statistics"
    echo "5. Real-time Monitoring"
    echo "6. Search and Filter"
    echo "7. Exit"
}

# Function to handle menu choices
interactive_mode() 
{
    while true; do
        display_menu
        echo "Choose an option:"
        read choice

        case "$choice" in
            1)
                list_processes
                ;;
            2)
                echo "Enter PID:"
                read pid
                process_info "$pid"
                ;;
            3)
                echo "Enter PID:"
                read pid
                kill_process "$pid"
                ;;
            4)
                system_statistics
                ;;
            5)
                real_time_monitoring
                ;;
            6)
                search_processes
                ;;
            7)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid option. Please choose a valid option."
                ;;
        esac
    done
}

# Load configuration
load_config

#log_activity

# Run interactive mode
interactive_mode

