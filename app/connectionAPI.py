import psycopg2
from flask import Flask, request, jsonify
import json
import boto3
from botocore.exceptions import ClientError

app = Flask(__name__)

def get_secret():
    """Retrieve database password from AWS Secrets Manager"""
    secret_name = "rds/username/password"
    region_name = "us-west-2"

    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=region_name)

    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret = json.loads(response['SecretString'])  # Ensure it's parsed as a dictionary
        return secret.get('password')
    except ClientError as e:
        print("Failed to retrieve password from AWS Secrets Manager")
        raise e

def check_db_connection():
    """Check if the database connection is successful"""
    try:
        password = get_secret()
        if not password:
            print("No password retrieved from Secrets Manager")
            return False

        with psycopg2.connect(
            dbname='fern',
            user='fern_admin',
            password=password,
            host='fern-rds-db-instance.cz2kgwecm6ep.us-west-2.rds.amazonaws.com',
            port='5432'
        ) as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT 1")  # Run a simple query to check connection
        return True
    except Exception as e:
        print(f"Database connection failed: {e}")
        return False

@app.before_request
def before_request():
    """Check DB connection before handling any request"""
    if not check_db_connection():
        return jsonify({"error": "Database unavailable"}), 503

@app.route('/')
def home():
    """Sample route that will only execute if DB is available"""
    return jsonify({"Status": "200! Database is connected."})

if __name__ == '__main__':
    app.run(debug=True)  # Flask starts normally, but every request checks the DB
