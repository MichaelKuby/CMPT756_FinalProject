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
    logger.info("Received event: %s", json.dumps(event))

    # Check if the event has a 'body' attribute, and parse it if present
    body = json.loads(event['body']) if 'body' in event else event

    iterations = int(body.get('iterations', 1))
    dimension = int(body.get('dimension', 100))

    A = [[1 if i == j else 0 for j in range(dimension)] for i in range(dimension)]
    B = [[1 if i == j else 0 for j in range(dimension)] for i in range(dimension)]

    start_time = time.perf_counter()

    for iteration_number in range(iterations):
        B = MatrixMult.matrix_multiplication(B, A)

    end_time = time.perf_counter()
    elapsed_time = end_time - start_time

    # Log the final matrix B (only feasible for small matrices)
    logger.info("Final matrix B after %d iterations:", iterations)
    for row in B:
        logger.info(row)

    # Create a response object with limited information due to size restrictions
    result = {
        "startTime": start_time,
        "endTime": end_time,
        "elapsedTime": elapsed_time,
        "message": "Matrix multiplication completed successfully"
    }

    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(result)
    }
