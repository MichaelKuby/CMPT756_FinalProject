#!/bin/bash

API_URL="https://2q26c54eti.execute-api.us-east-2.amazonaws.com/default/MatrixMult"

iterations=(50 50 50 50 50)
dimension=200
sleep_duration=10

LOG_DIR="log"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
CSV_FILE="${LOG_DIR}/lambda_test_log_${TIMESTAMP}.csv"

# Include the total_process_duration header
echo "dimension,iterations,trip_Loops,sleep_Duration,current_trip_loops_index,execution_time,network_delay,total_time_spent,Init_duration" > "$CSV_FILE"

if ! command -v jq &> /dev/null
then
    echo "jq could not be found, please install jq to format JSON output."
    exit 1
fi

process_start_time=$(python -c 'import time; print(time.time())')
prev_end_time=$process_start_time

cumulative_execution_time=0
cumulative_sleep_time=0
total_iterations=${#iterations[@]}
last_index=$((total_iterations - 1))
csv_content=()

for index in "${!iterations[@]}"
do
    i=${iterations[$index]}
    current_trip_loops_index=$((index + 1))
    echo "Testing with ${i} iterations and matrix dimension ${dimension}..."
    
    iteration_start_time=$(python -c 'import time; print(time.time())')
    
    response=$(curl -s -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -d "{\"iterations\": $i, \"dimension\": ${dimension}}")
    
    iteration_end_time=$(python -c 'import time; print(time.time())')
    # execution_time=$(echo "$iteration_end_time - $iteration_start_time" | bc)
    execution_time=$(echo "$response" | jq -r '.elapsedTime')
    cumulative_execution_time=$(echo "$cumulative_execution_time + $execution_time" | bc)
    
    network_delay=$(echo "$iteration_end_time - $iteration_start_time - $execution_time" | bc)
    # if [ $index -eq 0 ]; then
    #     network_delay=$(echo "$iteration_start_time - $process_start_time" | bc)
    # else
    #     cumulative_sleep_time=$(echo "$cumulative_sleep_time + $sleep_duration" | bc)
    #     network_delay=$(echo "$iteration_start_time - $prev_end_time - $sleep_duration" | bc)
    # fi
    prev_end_time=$iteration_end_time
    
    total_time_spent=$(echo "$cumulative_execution_time + $cumulative_sleep_time" | bc)
    
    # Store the row in an array for later use
    csv_content+=("${dimension},${i},${total_iterations},${sleep_duration},${current_trip_loops_index},${execution_time},${network_delay}")
    
    # Sleep only if not the last iteration
    if [ "$index" -ne "$last_index" ]; then
        echo "Sleeping for ${sleep_duration} seconds..."
        sleep $sleep_duration
    fi
done

process_end_time=$(python -c 'import time; print(time.time())')
total_process_duration=$(echo "$process_end_time - $process_start_time" | bc)

# Now iterate over the stored CSV content and append the total_process_duration to each line
for row in "${csv_content[@]}"
do
    echo "${row},${total_process_duration}" >> "$CSV_FILE"
done
