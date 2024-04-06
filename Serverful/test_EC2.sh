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

# Variables from the arguments
VM_IP="$1"
MATRIX_DIMENSIONS="$2"
MATRIX_MULTIPLICATIONS="$3"
ROUND_TRIP_LOOPS="$4"
SLEEP_DURATION="$5"

# Log and output directories setup
LOG_DIR="log"
mkdir -p "$LOG_DIR"  # Ensure the log directory exists

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
CSV_FILE="${LOG_DIR}/EC2_test_log_${TIMESTAMP}.csv"
OUTPUT_DIR="results"
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="${OUTPUT_DIR}/output_result_${TIMESTAMP}.txt"

# Static variables
VM_USER="ec2-user"
VM_PRIVATE_KEY_PATH="2024_sp_vm_instance.pem"
VM_SCRIPT_PATH="/home/ec2-user/matrixMult.py"

# CSV header
echo "iteration,startTime,endTime,elapsedTime" > "$CSV_FILE"

# Initial log in the output file
echo "Dimensions: $MATRIX_DIMENSIONS, Matrix Multiplications: $MATRIX_MULTIPLICATIONS, Loop Times: $ROUND_TRIP_LOOPS, Sleep Duration: $SLEEP_DURATION seconds" > "$OUTPUT_FILE"
echo "Test started at $(date)" >> "$OUTPUT_FILE"

# Initialize the start time
Initial_Start_Time=$(gdate +%s.%3N)
Initial_Start_Time_str=$(gdate -d "@$Initial_Start_Time" +"%Y-%m-%d %H:%M:%S.%3N")

# Main loop to run the VM script and log each iteration
for (( i=1; i<=ROUND_TRIP_LOOPS; i++ ))
do
    echo "-------- Iteration: $i --------" | tee -a "$OUTPUT_FILE"

    # Execute the script on the VM and append its output to the output file
    ssh -i "$VM_PRIVATE_KEY_PATH" ${VM_USER}@${VM_IP} "python3 ${VM_SCRIPT_PATH} ${MATRIX_DIMENSIONS} ${MATRIX_MULTIPLICATIONS}" | tee -a "$OUTPUT_FILE"

    # Log the iteration details in the CSV
    echo "$START_TIME,$END_TIME,$ELAPSED_TIME" >> "$CSV_FILE"

    # Sleep for the specified duration before starting the next iteration
    sleep $SLEEP_DURATION
done

Final_Time=$(gdate +%s.%3N)
Final_Time_str=$(gdate -d "@$Final_Time" +"%Y-%m-%d %H:%M:%S.%3N")
echo "Final Time: $Final_Time_str" | tee -a "$OUTPUT_FILE"

Total_time_spent=$(echo "$Final_Time - $Initial_Start_Time" | bc)
echo "Total time spent: $Total_time_spent seconds" | tee -a "$OUTPUT_FILE"

# Log the iteration details in the CSV
echo "$i,$START_TIME,$END_TIME,$ELAPSED_TIME" >> "$CSV_FILE"