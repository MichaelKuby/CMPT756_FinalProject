#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <VM_IP> <LOOP_TIMES> <VM_SCRIPT_PARAM>"
    exit 1
fi

# Example
# ./local_loop_run_matrixMult.sh ec2-3-16-159-225.us-east-2.compute.amazonaws.com 25 10 

VM_USER="ec2-user"
VM_IP="$1"
VM_PRIVATE_KEY_PATH="/Users/yycouple/Documents/SFU/Distributed_Cloud_Systems/Final_Project/2024_sp_vm_instance.pem"
VM_SCRIPT_PATH="/home/ec2-user/matrixMult.py"
LOOP_TIMES="$3"
VM_SCRIPT_PARAM="$2"  


Initial_Start_Time=$(gdate +%s.%3N)
Initial_Start_Time_str=$(gdate -d "@$Initial_Start_Time" +"%Y-%m-%d %H:%M:%S.%3N")

OUTPUT_DIR="$(dirname "$0")/results"
OUTPUT_FILE="$OUTPUT_DIR/output_result_$Initial_Start_Time_str.txt"
mkdir -p "$OUTPUT_DIR"
> "$OUTPUT_FILE"


echo "Initial Start Time: $Initial_Start_Time_str" | tee -a "$OUTPUT_FILE"


for (( i=1; i<=LOOP_TIMES; i++ ))
do
    echo "--------" | tee -a "$OUTPUT_FILE"
    echo "Current Times Index: $i" | tee -a "$OUTPUT_FILE"

    START_TIME=$(gdate +%s.%3N)
    echo "Start Time: $(gdate -d "@$START_TIME" +"%Y-%m-%d %H:%M:%S.%3N")" | tee -a "$OUTPUT_FILE"

    ssh -i "$VM_PRIVATE_KEY_PATH" ${VM_USER}@${VM_IP} "python3 ${VM_SCRIPT_PATH} ${VM_SCRIPT_PARAM}" >> "$OUTPUT_FILE"

    END_TIME=$(gdate +%s.%3N)
    echo "End Time: $(gdate -d "@$END_TIME" +"%Y-%m-%d %H:%M:%S.%3N")" | tee -a "$OUTPUT_FILE"

    echo "--------" | tee -a "$OUTPUT_FILE"

done

Final_Time=$(gdate +%s.%3N)
Final_Time_str=$(gdate -d "@$Final_Time" +"%Y-%m-%d %H:%M:%S.%3N")
echo "Final Time: $Final_Time_str" | tee -a "$OUTPUT_FILE"

Total_time_spent=$(echo "$Final_Time - $Initial_Start_Time" | bc)
echo "Total time spent: $Total_time_spent seconds" | tee -a "$OUTPUT_FILE"