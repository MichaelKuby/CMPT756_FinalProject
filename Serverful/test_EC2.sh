#!/bin/bash

################### USE ###################

# 1) Connect to the VM: ssh -i <PATH TO PRIVATE KEY> <VM_USER>@<VM_IP>
# Example: ssh -i 2024_sp_vm_instance.pem ec2-user@ec2-52-15-76-2.us-east-2.compute.amazonaws.com

# 2) Move a local file to the VM: scp -i <PATH TO PRIVATE KEY> <LOCAL_FILE> <VM_USER>@<VM_IP>:<VM_PATH>
# Example: scp -i 2024_sp_vm_instance.pem matrixMult.py ec2-user@ec2-52-15-76-2.us-east-2.compute.amazonaws.com:~

# 3) Run the script: ./test_EC2.sh <VM_IP> <MATRIX_DIMENSIONS> <MATRIX_MULTIPLICATIONS> <ROUND_TRIP_LOOPS> <SLEEP_DURATION>
# Example: ./test_EC2.sh ec2-52-15-76-2.us-east-2.compute.amazonaws.com 10 1 1 0

# Check if the correct number of arguments is passed
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <VM_IP> <MATRIX_DIMENSIONS> <MATRIX_MULTIPLICATIONS> <ROUND_TRIP_LOOPS> <SLEEP_DURATION>"
    exit 1
fi

#!/bin/bash

# Variables from the arguments
VM_IP="$1"
MATRIX_DIMENSIONS="$2"
MATRIX_MULTIPLICATIONS="$3"
ROUND_TRIP_LOOPS="$4"
SLEEP_DURATION="$5"

# Setup log and output directories
LOG_DIR="log"
mkdir -p "$LOG_DIR"  
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
CSV_FILE="${LOG_DIR}/EC2_test_log_${TIMESTAMP}.csv"
OUTPUT_DIR="results"
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="${OUTPUT_DIR}/output_result_${TIMESTAMP}.txt"

# CSV header similar to the second script
echo "iteration,dimension,startTime,endTime,elapsedTime,delay,sleepDuration,processElapsedTime" > "$CSV_FILE"

# Initial log in the output file (adapt as needed)
echo "Test Parameters: Dimensions: $MATRIX_DIMENSIONS, Multiplications: $MATRIX_MULTIPLICATIONS, Loops: $ROUND_TRIP_LOOPS, Sleep: $SLEEP_DURATION" > "$OUTPUT_FILE"

process_start_time=$(date +%s.%N) # Capture the overall start time for process elapsed time calculation

prev_end_time=0
for (( i=1; i<=ROUND_TRIP_LOOPS; i++ ))
do
    iteration_start_time=$(date +%s.%N)
    
    # Your existing logic here for the iteration execution

    iteration_end_time=$(date +%s.%N)
    elapsedTime=$(echo "$iteration_end_time - $iteration_start_time" | bc)
    
    # Calculate delay if not the first iteration
    if [ $i -gt 1 ]; then
        delay=$(echo "$iteration_start_time - $prev_end_time" | bc)
    else
        delay=0
    fi
    prev_end_time=$iteration_end_time
    
    process_elapsed_time=$(echo "$iteration_end_time - $process_start_time" | bc)
    
    echo "$i,$MATRIX_DIMENSIONS,$iteration_start_time,$iteration_end_time,$elapsedTime,$delay,$SLEEP_DURATION,$process_elapsed_time" >> "$CSV_FILE"
    
    # Optional: Log iteration details to the output file similar to the CSV log

    sleep $SLEEP_DURATION
done

# Log the total process duration similarly to the second script
process_end_time=$(date +%s.%N)
total_process_duration=$(echo "$process_end_time - $process_start_time" | bc)
echo "Total process duration: $total_process_duration seconds" | tee -a "$OUTPUT_FILE"