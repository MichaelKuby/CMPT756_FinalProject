#!/bin/bash

# API endpoint URL
API_URL="https://2q26c54eti.execute-api.us-east-2.amazonaws.com/default/MatrixMult"

# Array of iteration counts to test
iterations=(1 2 3 4 5 6 7 8 9 10 20 30 40 50 60 70 80 90 100)

# Log directory and file name
LOG_DIR="log"
mkdir -p "$LOG_DIR"  # Create log directory if it doesn't exist

# Timestamp for the log file name
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# CSV file name with timestamp
CSV_FILE="${LOG_DIR}/lambda_test_log_${TIMESTAMP}.csv"

# Start new log session and write CSV header
echo "iteration,startTime,endTime,elapsedTime,delay" > "$CSV_FILE"

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found, please install jq to format JSON output."
    exit 1
fi

# Initialize previous end time as 0
prev_end_time=0

# Loop through the iteration counts and test each one
for i in "${iterations[@]}"
do
    echo "Testing with ${i} iterations..."
    response=$(curl -s -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -d "{\"iterations\": $i}")
    
    # Parse response using jq
    startTime=$(echo "$response" | jq -r '.startTime')
    endTime=$(echo "$response" | jq -r '.endTime')
    elapsedTime=$(echo "$response" | jq -r '.elapsedTime')

    # Calculate delay
    if [ "$prev_end_time" != 0 ]; then
        delay=$(echo "$startTime - $prev_end_time" | bc)
        delay=$(printf "%.6f" "$delay")  # Format the delay to include leading zero
    else
        delay=0
    fi
    prev_end_time=$endTime

    # Write to CSV
    echo "${i},${startTime},${endTime},${elapsedTime},${delay}" >> "$CSV_FILE"
done