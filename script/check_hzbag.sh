#!/bin/bash

# 1. Check if ROS1 is available
if ! command -v rosbag &> /dev/null; then
    echo "ROS1 Noetic is not sourced."
    exit 1
fi

# 2. Check if a bag file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_bag_file.bag>"
    exit 1
fi

BAG_FILE="$1"

# 3. Extract Duration and handle the M:SS format
# This grabs the value inside the parentheses, e.g., (66s) -> 66
RAW_DURATION=$(rosbag info "$BAG_FILE" | grep "duration:" | grep -oP '\(\K[^)]+' | tr -d 's')

if [ -z "$RAW_DURATION" ]; then
    # Fallback if parentheses aren't there
    RAW_DURATION=$(rosbag info "$BAG_FILE" | grep "duration:" | awk '{print $2}' | tr -d 's')
fi

echo "----------------------------------------------------------------------------------------"
echo "Calculating topic frequencies for: $BAG_FILE"
echo "Total Duration: ${RAW_DURATION} seconds"
echo "----------------------------------------------------------------------------------------"

# 4. Extract Topics and Counts
# We start reading after the "topics:" line
rosbag info "$BAG_FILE" | sed -n '/topics:/,$p' | tail -n +2 | while read -r line; do
    # Extract topic name and message count
    topic=$(echo "$line" | awk '{print $1}')
    count=$(echo "$line" | awk '{print $2}')
    
    # Only process if count is a number
    if [[ "$count" =~ ^[0-9]+$ ]]; then
        # Perform calculation using awk (standard in almost all distros)
        frequency=$(awk -v c="$count" -v d="$RAW_DURATION" 'BEGIN { if (d>0) printf "%.2f", c / d; else print "0.00" }')
        printf "Topic: %-50s Frequency: %7s Hz\n" "$topic" "$frequency"
    fi
done

echo "----------------------------------------------------------------------------------------"