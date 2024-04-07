#!/bin/bash

################### Configuration ###################
# ~/.ssh/config
# add
# Host CMPT756-ec2-instance
#   HostName ec2-18-223-149-168.us-east-2.compute.amazonaws.com // DNS
#   User ec2-user
#   IdentityFile ~/Documents/SFU/Distributed_Cloud_Systems/Final_Project/CMPT756_FinalProject/Serverful/2024_sp_vm_instance.pem // your private key path
#   ControlMaster auto
#   ControlPath ~/.ssh/cm_sockets/%C // Make sure you have created the folder "cm_sockets"
#   ControlPersist 600 // This means that the control master connection will remain open for 600 seconds (10 minutes) after the last SSH session. During these 600 seconds, any new SSH connections will attempt to reuse the control master connection, thereby speeding up connection establishment.

################### USE ###################
# 1.0) Config as above

# 1.1) Use "ssh CMPT756-ec2-instance" commend to connect to the ec2-instance

# 2) Move a local file to the VM: scp -i <PATH TO PRIVATE KEY> <LOCAL_FILE> <VM_USER>@<VM_IP>:<VM_PATH>
# Example: scp -i 2024_sp_vm_instance.pem matrixMult.py ec2-user@ec2-52-15-76-2.us-east-2.compute.amazonaws.com:~

# 3) Run the script: ./local_loop_run_matrixMult_V2.sh <MATRIX_DIMENSIONS> <MATRIX_MULTIPLICATIONS> <ROUND_TRIP_LOOPS> <SLEEP_DURATION>
# Example: ./local_loop_run_matrixMult_V2.sh 15 10 10 2
################### USE END ###################

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <MATRIX_DIMENSIONS> <MATRIX_MULTIPLICATIONS> <ROUND_TRIP_LOOPS> <SLEEP_DURATION>"
    exit 1
fi

VM_USER="ec2-user"
VM_PRIVATE_KEY_PATH="./2024_sp_vm_instance.pem"
VM_SCRIPT_PATH="/home/ec2-user/matrixMult.py"

MATRIX_DIMENSIONS="$1"
MATRIX_MULTIPLICATIONS="$2"
ROUND_TRIP_LOOPS="$3"
SLEEP_DURATION="$4"

Initial_Start_Time=$(gdate +%s.%3N)
Initial_Start_Time_str=$(gdate -d "@$Initial_Start_Time" +"[%Y-%m-%d]%H:%M:%S.%3N")


OUTPUT_DIR="$(dirname "$0")/results/$MATRIX_DIMENSIONS,$MATRIX_MULTIPLICATIONS,$ROUND_TRIP_LOOPS,$SLEEP_DURATION==>$Initial_Start_Time_str"
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="${OUTPUT_DIR}/output.log"
CSV_FILE="${OUTPUT_DIR}/result.csv"


echo "Initial_Start_Time: $Initial_Start_Time_str"| tee -a "$OUTPUT_FILE"
echo "Dimensions: $MATRIX_DIMENSIONS" | tee -a "$OUTPUT_FILE"
echo "Iterations: $MATRIX_MULTIPLICATIONS"| tee -a "$OUTPUT_FILE"
echo "Trip_Loops: $ROUND_TRIP_LOOPS"| tee -a "$OUTPUT_FILE"
echo "Sleep_Duration: $SLEEP_DURATION"| tee -a "$OUTPUT_FILE"

echo "dimensions,iterations,trip_Loops,sleep_Duration,current_trip_loops_index,execution_time,network_delay,total_time_spent" > "$CSV_FILE"


for (( i=1; i<=ROUND_TRIP_LOOPS; i++ ))
do
    echo "--------"| tee -a "$OUTPUT_FILE"
    echo "Current Trip Loops Index: $i"| tee -a "$OUTPUT_FILE"

    START_TIME=$(gdate +%s.%3N)
    echo "Start Time: $(gdate -d "@$START_TIME" +"%Y-%m-%d %H:%M:%S.%3N")"| tee -a "$OUTPUT_FILE"

    SSH_OUTPUT=$(mktemp)
    ssh CMPT756-ec2-instance "python3 ${VM_SCRIPT_PATH} ${MATRIX_DIMENSIONS} ${MATRIX_MULTIPLICATIONS}" | tee "$SSH_OUTPUT" | tee -a "$OUTPUT_FILE"

    EXEC_TIME=$(grep "The code executed in" "$SSH_OUTPUT" | awk '{print $5}')
    echo "Execution time spent: $EXEC_TIME seconds" | tee -a "$OUTPUT_FILE"
    rm "$SSH_OUTPUT"

    END_TIME=$(gdate +%s.%3N)
    echo "End Time: $(gdate -d "@$END_TIME" +"%Y-%m-%d %H:%M:%S.%3N")" | tee -a "$OUTPUT_FILE"
    
    DELAY=$(echo "$END_TIME - $START_TIME - $EXEC_TIME" | bc)
    echo "Network delay spent: $DELAY seconds" | tee -a "$OUTPUT_FILE"

    echo "--------" | tee -a "$OUTPUT_FILE"


    # Write to CSV
    echo "${MATRIX_DIMENSIONS},${MATRIX_MULTIPLICATIONS},${ROUND_TRIP_LOOPS},${SLEEP_DURATION},${i},${EXEC_TIME},${DELAY},0" >> "$CSV_FILE"

    if [ "$i" -ne "$ROUND_TRIP_LOOPS" ] && [ "$SLEEP_DURATION" -gt 0 ]; then
        echo "Sleeping for ${SLEEP_DURATION} seconds..." | tee -a "$OUTPUT_FILE"
        sleep $SLEEP_DURATION
    fi

done

Final_Time=$(gdate +%s.%3N)
Final_Time_str=$(gdate -d "@$Final_Time" +"%Y-%m-%d %H:%M:%S.%3N")
echo "Final Time: $Final_Time_str" | tee -a "$OUTPUT_FILE"

Total_time_spent=$(echo "$Final_Time - $Initial_Start_Time" | bc)
echo "Total time spent: $Total_time_spent seconds" | tee -a "$OUTPUT_FILE"

awk -v total="$Total_time_spent" 'BEGIN {FS=OFS=","} {if(NR>1) $8=total; print}' "$CSV_FILE" > "${CSV_FILE}.tmp"
mv "${CSV_FILE}.tmp" "$CSV_FILE"
