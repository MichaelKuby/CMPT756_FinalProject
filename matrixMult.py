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
                    
        return

if __name__ == "__main__":
    start_time = time.perf_counter()
    # get input arg from command line
    mode = sys.argv[1]
    
    if mode == 's':
        # compute a 3 * 3 matrix multiplication
        A = [[i for i in range(5)] for _ in range(5)]
        B = [[i for i in range(5)] for _ in range(5)]
    elif mode == 'm':
        # compute a 500 * 500 matrix multiplication
        A = [[i for i in range(500)] for _ in range(500)]
        B = [[i for i in range(500)] for _ in range(500)]
    elif mode == 'l':
        # compute a 10000 * 10000 matrix multiplication
        A = [[i for i in range(1000)] for _ in range(1000)]
        B = [[i for i in range(1000)] for _ in range(1000)]
    else:
        print("Invalid mode. Please use 's' for small, 'm' for medium, or 'l' for large.")
        sys.exit()

    MatrixMult.matrix_multiplication(A, B)
    
    end_time = time.perf_counter()
    elapsed_time = end_time - start_time
    print(f"The code executed in {elapsed_time} seconds.")