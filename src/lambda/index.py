import json
import os


def lambda_handler(event, context):
    env = os.environ["TEST_STR"]
    print(env)

    return {"statusCode": 200, "body": json.dumps("Hello from Lambda!")}
