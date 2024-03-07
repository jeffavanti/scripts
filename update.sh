#!/bin/bash

# Variables
cpu=$(/usr/sbin/sysctl -n machdep.cpu.brand_string)
os_vers=$(/usr/bin/sw_vers -productVersion)
sonoma_max=14.3.1
sonoma_min=14.0.0
ventura_max=13.6.4
ventura_min=13.0.0
monterey_max=12.7.3
monterey_min=12.0.0

# Check to see what CPU is installed
if [ "$cpu" == "Apple M3 Pro" ]; then
    echo "Computer is running Apple Silicon"
fi

# Function to compare version numbers within a range
compare_version() {
    if [ "$(printf "%s\n" "$os_vers" "$sonoma_min" "$sonoma_max" | sort -V | tail -n 1)" == "$sonoma_max" ]; then
        echo "Computer is running Sonoma"
    elif [ "$(printf "%s\n" "$os_vers" "$ventura_min" "$ventura_max" | sort -V | tail -n 1)" == "$ventura_max" ]; then
        echo "Computer is running Ventura"
    elif [ "$(printf "%s\n" "$os_vers" "$monterey_min" "$monterey_max" | sort -V | tail -n 1)" == "$monterey_max" ]; then
        echo "Computer is running Monterey"
    fi
}

# Call the function to compare macOS version
compare_version
