import json
import psycopg2
import os
from datetime import datetime

# 環境変数から接続情報を取得
DB_HOST = os.environ["DB_HOST_PORT"].split(":")[0]
DB_NAME = os.environ["DB_NAME"]
DB_USER = os.environ["DB_USER"]
DB_PASSWORD = os.environ["DB_PASSWORD"]


def datetime_converter(o):
    if isinstance(o, datetime):
        return o.isoformat()


def get_db_connection():
    connection = psycopg2.connect(
        host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASSWORD
    )
    return connection


def lambda_handler(event, context):
    operation = event.get("operation", "read")

    if operation == "create":
        return create_user(event["user"])
    elif operation == "read":
        # return read_user(event["user_id"])
        return read_user(event.get("user_id", None))
    elif operation == "update":
        return update_user(event["user_id"], event["user"])
    elif operation == "delete":
        return delete_user(event["user_id"])
    else:
        return {"statusCode": 400, "body": json.dumps("Invalid operation")}


def create_user(user):
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute(
        "INSERT INTO users (name, email, password_hash) VALUES (%s, %s, %s)",
        (user["name"], user["email"], user["password_hash"]),
    )
    connection.commit()
    cursor.close()
    connection.close()
    return {"statusCode": 201, "body": json.dumps("User created successfully")}


def read_user(user_id):
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM users")  # WHERE user_id = %s", (user_id,))
    user = cursor.fetchall()
    column_names = [desc[0] for desc in cursor.description]

    results = []
    for u in user:
        results.append(dict(zip(column_names, u)))

    # JSON形式に変換
    json_results = json.dumps(results, default=datetime_converter)

    cursor.close()
    connection.close()

    return {"statusCode": 200, "body": json_results}


def update_user(user_id, user):
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute(
        "UPDATE users SET name = %s, email = %s, password_hash = %s \
            WHERE user_id = %s",
        (user["name"], user["email"], user["password_hash"], user_id),
    )
    connection.commit()
    cursor.close()
    connection.close()
    return {"statusCode": 200, "body": json.dumps("User updated successfully")}


def delete_user(user_id):
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute("DELETE FROM users WHERE user_id = %s", (user_id,))
    connection.commit()
    cursor.close()
    connection.close()
    return {"statusCode": 200, "body": json.dumps("User deleted successfully")}
