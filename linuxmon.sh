#!/bin/bash

LOG_DIR="/var/linuxmon/log"

get_timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# Function to get the process name by PID
get_process_name() {
    local pid=$1
    local process_name=$(ps -p "$pid" -o comm= 2>/dev/null)
    echo "$process_name"
}

# Function to get the script's process ID
get_script_pid() {
    local script_pid=$$
    echo "$script_pid"
}

monitor_process_creations() {
    script_pid=$(get_script_pid)
    
    while true; do
        ps -eo pid,ppid,cmd --no-headers | while read -r pid ppid cmd; do
            if [[ $pid != $script_pid ]]; then
                if ! grep -q "$pid" "$LOG_DIR/process_ids.txt"; then
                    process_name=$(get_process_name "$pid")
                    if [[ $cmd == *mysqldump* || $cmd == *pg_dump* || $cmd == *mongo*dump* || $cmd == *elastic*dump* || $cmd == *redis*dump* ]]; then
                        echo -e "$(get_timestamp)\tProcess tried to dump database\tPID=$pid\tPPID=$ppid\tCMD=$cmd\tName=$process_name" >> "$LOG_DIR/database_dump_attempts.log"
                    elif [[ $cmd == *sudo* ]]; then
                        echo -e "$(get_timestamp)\tProcess created with sudo\tPID=$pid\tPPID=$ppid\tCMD=$cmd\tName=$process_name" >> "$LOG_DIR/process_creations.log"
                    else
                        echo -e "$(get_timestamp)\tProcess created\tPID=$pid\tPPID=$ppid\tCMD=$cmd\tName=$process_name" >> "$LOG_DIR/process_creations.log"
                    fi
                    echo "$pid" >> "$LOG_DIR/process_ids.txt"
                fi
            fi
        done
        sleep 1
    done
}

# Function to monitor process terminations
monitor_process_terminations() {
    while true; do
        while read -r pid; do
            if ! ps -p "$pid" > /dev/null; then
                process_name=$(get_process_name "$pid")
                echo -e "$(get_timestamp)\tProcess terminated\tPID=$pid\tName=$process_name" >> "$LOG_DIR/process_terminations.log"
                sed -i "/$pid/d" "$LOG_DIR/process_ids.txt"
            fi
        done < <(pgrep -d ' ' -P 1)
        sleep 1
    done
}

monitor_network_connections() {
    tcpdump -l -i eth0 | while read -r line; do
        echo -e "$(get_timestamp)\tNetwork activity\t$line" >> "$LOG_DIR/network_activity.log"
    done
}

# Function to monitor library loads
monitor_library_loads() {
    while true; do
        lsof -r1 -c . -a -d txt,m86 -d mem -F n | while read -r line; do
            if [[ $line == n* ]]; then
                echo -e "$(get_timestamp)\tLibrary load\t${line:1}" >> "$LOG_DIR/library_loads.log"
            fi
        done
        sleep 1
    done
}

# Main function
main() {
    echo "Monitoring Linux activities..."

    # Create log directory if it doesn't exist
    mkdir -p "$LOG_DIR"

    # Start monitoring process creations in the background
    monitor_process_creations &

    # Start monitoring process terminations in the background
    monitor_process_terminations &

    # Start monitoring network connections in the background
    monitor_network_connections &

    # Start monitoring library loads in the background
    monitor_library_loads &

    # Wait for user input to stop monitoring
    read -rp "Press any key to stop monitoring..."

    # Terminate background processes
    pkill -P $$

    echo "Monitoring stopped. Logs saved in $LOG_DIR"
}

# Run the main function
main
