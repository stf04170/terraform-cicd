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
    print(event)
    path = event.get("resource", None)
    method = event.get("httpMethod", None)

    if path == "/api/users":
        if method == "GET":
            return read_user()
        elif method == "POST":
            return create_user(event)
        else:
            return {"statusCode": 400, "body": json.dumps("Invalid method")}
    elif path == "/api/user/{user_id}":
        user_id_str = event.get("pathParameters", []).get("user_id", None)
        print(user_id_str)
        if not user_id_str or not user_id_str.isdecimal():
            return {"statusCode": 400, "body": json.dumps("Invalid user_id")}

        if method == "GET":
            return read_user(int(user_id_str))
        elif method == "PUT":
            return update_user(int(user_id_str), event)
        elif method == "DELETE":
            return delete_user(int(user_id_str))
        else:
            return {"statusCode": 400, "body": json.dumps("Invalid method")}
    else:
        return {"statusCode": 400, "body": json.dumps("Invalid request")}


def create_user(event):
    if not event.get("body"):
        return {"statusCode": 400, "body": json.dumps("Cannot found User data")}
    json_str = event.get("body", [])
    print(json_str)
    user = json.loads(json_str)

    if "name" not in user or "email" not in user or "password_hash" not in user:
        return {"statusCode": 400, "body": json.dumps("Incorrect User data")}

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


def read_user(user_id=None):
    connection = get_db_connection()
    cursor = connection.cursor()
    if not user_id:
        cursor.execute("SELECT * FROM users")
    else:
        cursor.execute("SELECT * FROM users WHERE user_id = %s", (user_id,))
    user = cursor.fetchall()
    column_names = [desc[0] for desc in cursor.description]

    results = []
    for u in user:
        results.append(dict(zip(column_names, u)))

    # JSON形式に変換
    json_results = (
        json.dumps(results, default=datetime_converter) if results else "No Data"
    )

    cursor.close()
    connection.close()

    return {"statusCode": 200, "body": json_results}


def update_user(user_id, event):
    if not event.get("body"):
        return {"statusCode": 400, "body": json.dumps("Cannot found User data")}
    json_str = event.get("body", [])
    print(json_str)
    user = json.loads(json_str)

    connection = get_db_connection()
    cursor = connection.cursor()

    # 更新するカラムとその値を保持するリスト
    columns = []
    values = []

    if "name" in user:
        columns.append("name = %s")
        values.append(user["name"])
    if "email" in user:
        columns.append("email = %s")
        values.append(user["email"])
    if "password_hash" in user:
        columns.append("password_hash = %s")
        values.append(user["password_hash"])

    # カラムが指定されていない場合はエラーメッセージを返す
    if not columns:
        return {"statusCode": 400, "body": json.dumps("No fields to update")}

    # SET句をカンマで結合
    set_clause = ", ".join(columns)

    # SQL文を実行
    cursor.execute(
        f"UPDATE users SET {set_clause} WHERE user_id = %s",
        (*values, user_id),  # user_idを最後に追加
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
