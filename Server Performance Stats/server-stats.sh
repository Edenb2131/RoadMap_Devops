#!/bin/bash

# Function to detect the operating system
detect_os() {
    os=$(uname -s)
    case "$os" in
        Linux) echo "Linux";;
        Darwin) echo "macOS";;
        *) echo "Unsupported OS"; exit 1;;
    esac
}

# Function to get CPU usage
get_cpu_usage() {
    if [ "$os" = "Linux" ]; then
        usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    elif [ "$os" = "macOS" ]; then
        usage=$(top -l 1 | awk '/CPU usage/ {print $3}' | sed 's/%//')
    fi
    echo -e "CPU Usage:\t${usage}%"
}

# Function to get memory usage
get_memory_usage() {
    if [ "$os" = "Linux" ]; then
        free_output=$(free -m)
        total=$(echo "$free_output" | awk '/^Mem/ {print $2}')
        used=$(echo "$free_output" | awk '/^Mem/ {print $3}')
        percent=$(awk "BEGIN {printf \"%.2f\", ($used/$total)*100}")
    elif [ "$os" = "macOS" ]; then
        vm_stat=$(vm_stat)
        free_pages=$(echo "$vm_stat" | grep "Pages free:" | awk '{print $3}' | sed 's/\.//')
        total_memory=$((($(sysctl -n hw.memsize) / 1024) / 1024)) # in MB
        used_memory=$((total_memory - (free_pages * 4096 / 1024 / 1024)))
        percent=$(awk "BEGIN {printf \"%.2f\", ($used_memory/$total_memory)*100}")
    fi
    echo -e "Memory Usage:\t${used_memory} MB Used / ${total_memory} MB Total (${percent}%)"
}

# Function to get disk usage
get_disk_usage() {
    if [ "$os" = "Linux" ]; then
        df_output=$(df -h --total | grep 'total')
        total=$(echo "$df_output" | awk '{print $2}')
        used=$(echo "$df_output" | awk '{print $3}')
        percent=$(echo "$df_output" | awk '{print $5}')
    elif [ "$os" = "macOS" ]; then
        df_output=$(df -h /)
        total=$(echo "$df_output" | awk 'NR==2 {print $2}')
        used=$(echo "$df_output" | awk 'NR==2 {print $3}')
        percent=$(echo "$df_output" | awk 'NR==2 {print $5}')
    fi
    echo -e "Disk Usage:\t${used} Used / ${total} Total (${percent})"
}

# Function to get top 5 processes by CPU usage
get_top_cpu_processes() {
    echo -e "Top 5 Processes by CPU Usage:"
    if [ "$os" = "Linux" ]; then
        ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6 | awk '{print $1"\t"$2"\t"$3"%"}'
    elif [ "$os" = "macOS" ]; then
        ps aux | sort -nrk 3 | head -n 5 | awk '{print $2"\t"$11"\t"$3"%"}'
    fi
}

# Function to get top 5 processes by memory usage
get_top_memory_processes() {
    echo -e "Top 5 Processes by Memory Usage:"
    if [ "$os" = "Linux" ]; then
        ps -eo pid,comm,%mem --sort=-%mem | head -n 6 | awk '{print $1"\t"$2"\t"$3"%"}'
    elif [ "$os" = "macOS" ]; then
        ps aux | sort -nrk 4 | head -n 5 | awk '{print $2"\t"$11"\t"$4"%"}'
    fi
}

# Main script
os=$(detect_os)
echo -e "Detected OS:\t${os}"
echo "Server Performance Stats:"
get_cpu_usage
get_memory_usage
get_disk_usage
get_top_cpu_processes
get_top_memory_processes
