### How to use the .sh file
#### 1. Setting
- You need to install jq(command line JSON processor) for json object processing.
- You can install jq using brew using this command: brew install jq
- Make the script executable with this command: chmod +x test_lambda_jq.sh

#### 2. Set test parameters
- You modify the iterations variable in the .sh to set the test parameters
- iterations=(1 2 3 4 5 6 7 8 9 10 20 30 40 50 60 70 80 90 100)

#### 3. Run the code
- Run the code with command: ./test_lambda_jq.sh

#### 4. Check the log
- The logs are saved in the logs directory in a csv format.
