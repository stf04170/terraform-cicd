import json
import psycopg2
import os

# 環境変数から接続情報を取得
DB_HOST = os.environ["DB_HOST"]
DB_NAME = os.environ["DB_NAME"]
DB_USER = os.environ["DB_USER"]
DB_PASSWORD = os.environ["DB_PASSWORD"]


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
        return read_user(event["user_id"])
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
    user = cursor.fetchone()
    cursor.close()
    connection.close()
    return {"statusCode": 200, "body": json.dumps(user)}


def update_user(user_id, user):
    connection = get_db_connection()
    cursor = connection.cursor()
    cursor.execute(
        "UPDATE users SET name = %s, email = %s, password_hash = %s WHERE user_id = %s",
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
