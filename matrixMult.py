import sys
import time

# To run from the command line:
# time python matrixMult.py s or m or l
# Runs sequentially

class MatrixMult():
    def matrix_multiplication(A, B):
        """
        Manually implements matrix multiplication in a sequential manner.
        
        Parameters:
        A (list of lists): The first matrix.
        B (list of lists): The second matrix.
        
        Returns:
        result (list of lists): The result of multiplying matrix A by matrix B.
        """
        # Number of rows in the first matrix
        rows_A = len(A)
        # Number of columns in the first matrix (and rows in the second matrix)
        cols_A = len(A[0])
        # Number of columns in the second matrix
        cols_B = len(B[0])
        
        # Initialize the result matrix with zeros
        result = [[0 for _ in range(cols_B)] for _ in range(rows_A)]
        
        # Perform the matrix multiplication
        for i in range(rows_A):
            for j in range(cols_B):
                for k in range(cols_A):
                    result[i][j] += A[i][k] * B[k][j]
                    
        return result

if __name__ == "__main__":
    start_time = time.perf_counter()

    # get input arg from command line
    iterations = sys.argv[1]

    # Check if the input is valid by ensuring it consists of only integers
    if not iterations.isdigit():
        print("Invalid input. Please enter an integer.")
        sys.exit()

    # Convert the input to an integer
    iterations = int(iterations)

    # Make a diagonal matrix with 1's on the diagonal
    A = [[1 if i == j else 0 for j in range(100)] for i in range(100)]

    for _ in range(iterations):
        A = MatrixMult.matrix_multiplication(A, A)
    
    end_time = time.perf_counter()
    
    elapsed_time = end_time - start_time

    # Determine the max width for the label text to ensure alignment
    label_width = max(len("The code started executing at"),
                    len("The code finished executing at"),
                    len("The code executed in"))

    # Print statements with formatted alignment
    print(f"{'The code started executing at':{label_width}} {start_time:15.6f} seconds.")
    print(f"{'The code finished executing at':{label_width}} {end_time:15.6f} seconds.")
    print(f"{'The code executed in':{label_width}} {elapsed_time:15.6f} seconds.")
