import subprocess
import sys
from datetime import datetime


def main(iterations):
    start_time = datetime.now()
    start_time_formatted = start_time.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]
    print(f'start_time: {start_time_formatted}')

    for i in range(iterations):
        print(f'current times index: {iterations}')
        subprocess.run(["python3", "/home/ec2-user/matrixMult.py", f"{iterations}"])

    end_time = datetime.now()
    end_time_formatted = end_time.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]
    print(f'end_time: {end_time_formatted}')

    total_time_delta = end_time - start_time
    total_seconds = total_time_delta.total_seconds()
    formatted_total_seconds = "{:.4f}".format(total_seconds)

    print(f'Total time: {formatted_total_seconds} seconds')


if __name__ == '__main__':
    times = sys.argv[1]
    # Check if the input is valid by ensuring it consists of only integers
    if not times.isdigit():
        print("Invalid input. Please enter an integer.")
        sys.exit()

    main(int(times))
