import sys
import time

# To run from the command line: python matrixMult.py dimensions iterations
# where 'dimensions' is the size of the square matrices and 'iterations' is the number of times to run the multiplication
# Runs sequentially

class MatrixMult():
    @staticmethod
    def matrix_multiplication(A, B):
        """
        Manually implements matrix multiplication in a sequential manner.
        
        Parameters:
        A (list of lists): The first matrix.
        B (list of lists): The second matrix.
        
        Returns:
        result (list of lists): The result of multiplying matrix A by matrix B.
        """
        rows_A = len(A)
        cols_A = len(A[0])
        cols_B = len(B[0])
        result = [[0 for _ in range(cols_B)] for _ in range(rows_A)]
        for i in range(rows_A):
            for j in range(cols_B):
                for k in range(cols_A):
                    result[i][j] += A[i][k] * B[k][j]
        return result

if __name__ == "__main__":
    start_time = time.perf_counter()

    if len(sys.argv) != 3:
        print("Usage: python matrixMult.py <dimensions> <iterations>")
        sys.exit(1)

    dimensions = sys.argv[1]
    iterations = sys.argv[2]

    # Validate inputs
    if not dimensions.isdigit() or not iterations.isdigit():
        print("Invalid input. Please enter integers for both dimensions and iterations.")
        sys.exit(1)

    dimensions = int(dimensions)
    iterations = int(iterations)

    # Generate square matrices A and B with 1's on the diagonal
    A = [[1 if i == j else 0 for j in range(dimensions)] for i in range(dimensions)]
    B = A.copy()

    for _ in range(iterations):
        B = MatrixMult.matrix_multiplication(B, A)
    
    end_time = time.perf_counter()
    elapsed_time = end_time - start_time

    label_width = max(len("The code started executing at"),
                      len("The code finished executing at"),
                      len("The code executed in"))

    print(f"{'The code started executing at':{label_width}} {start_time:15.6f} seconds.")
    print(f"{'The code finished executing at':{label_width}} {end_time:15.6f} seconds.")
    print(f"{'The code executed in':{label_width}} {elapsed_time:15.6f} seconds.")
