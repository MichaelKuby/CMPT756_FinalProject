import json
import time
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

class MatrixMult:
    @staticmethod
    def matrix_multiplication(A, B):
        rows_A = len(A)
        cols_A = len(A[0])
        cols_B = len(B[0])

        result = [[0 for _ in range(cols_B)] for _ in range(rows_A)]

        for i in range(rows_A):
            for j in range(cols_B):
                for k in range(cols_A):
                    result[i][j] += A[i][k] * B[k][j]

        return result

def handler(event, context):
    logger.info(f"Received event: {event}")

    # Parse the request body to get parameters
    body = json.loads(event.get('body', '{}'))

    # Get the number of iterations and matrix dimension from the event object
    iterations = int(body.get('iterations', 1))  # Default to 1 if not specified
    dimension = int(body.get('dimension', 100))  # Default to 100 if not specified

    # Create a square identity matrix of the specified dimension
    A = [[1 if i == j else 0 for j in range(dimension)] for i in range(dimension)]
    B = A

    start_time = time.perf_counter()
    
    for _ in range(iterations):
        B = MatrixMult.matrix_multiplication(B, A)

    end_time = time.perf_counter()
    elapsed_time = end_time - start_time

    # Create a response object
    result = {
        "startTime": start_time,
        "endTime": end_time,
        "elapsedTime": elapsed_time,
        "matrixA" : A,
        "matrixB" : B,
        "message": "Matrix multiplication completed successfully"
    }
    
    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(result)
    }
