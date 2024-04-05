#!/bin/bash
process_start_time=$(python -c 'import time; print(time.time())')

API_URL="https://2q26c54eti.execute-api.us-east-2.amazonaws.com/default/MatrixMult"

iterations=(10)
dimension=20
sleep_duration=0

LOG_DIR="log"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
CSV_FILE="${LOG_DIR}/lambda_test_log_${TIMESTAMP}.csv"

echo "iteration,dimension,startTime,endTime,elapsedTime,delay,sleepDuration,processElapsedTime" > "$CSV_FILE"

if ! command -v jq &> /dev/null
then
    echo "jq could not be found, please install jq to format JSON output."
    exit 1
fi


prev_end_time=0
last_index=$(( ${#iterations[@]} - 1 ))

for index in "${!iterations[@]}"
do
    i=${iterations[$index]}
    echo "Testing with ${i} iterations and matrix dimension ${dimension}..."
    response=$(curl -s -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -d "{\"iterations\": $i, \"dimension\": ${dimension}}")
    
    startTime=$(echo "$response" | jq -r '.startTime')
    endTime=$(echo "$response" | jq -r '.endTime')
    elapsedTime=$(echo "$response" | jq -r '.elapsedTime')
    matrixA=$(echo "$response" | jq '.matrixA')
    matrixB=$(echo "$response" | jq '.matrixB')

    # echo "Matrix A from iteration ${i}:"
    # echo "$matrixA"
    # echo "Matrix B from iteration ${i}:"
    # echo "$matrixB"

    if [ "$prev_end_time" != 0 ]; then
        delay=$(echo "$startTime - $prev_end_time" | bc)
        delay=$(printf "%.6f" "$delay")
    else
        delay=0
    fi
    prev_end_time=$endTime

    process_current_time=$(python -c 'import time; print(time.time())')
    process_elapsed_time=$(echo "$process_current_time - $process_start_time" | bc)

    echo "${i},${dimension},${startTime},${endTime},${elapsedTime},${delay},${sleep_duration},$(printf "%.6f" $process_elapsed_time)" >> "$CSV_FILE"
    
    # Only sleep if sleep_duration is greater than 0 and not the last iteration
    if [ "$index" -ne "$last_index" ] && [ "$sleep_duration" -gt 0 ]; then
        echo "Sleeping for ${sleep_duration} seconds..."
        sleep $sleep_duration
    fi
done

process_end_time=$(python -c 'import time; print(time.time())')
total_process_duration=$(echo "$process_end_time - $process_start_time" | bc)

echo "Total process duration: $(printf "%.6f" $total_process_duration)s" | tee -a "$CSV_FILE"
