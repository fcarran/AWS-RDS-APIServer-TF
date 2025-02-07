import psycopg2
from flask import Flask
import json
import boto3
from botocore.exceptions import ClientError

app = Flask(__name__)

def get_secret(): # AWS provided function to retrieve secret

    secret_name = "rds/username/password"
    region_name = "us-west-2"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        print(f"Failed to retrieve password from AWS Secrets Manager")
        raise e

    secret = get_secret_value_response['SecretString'] # dictionary object
    return secret.get('password')

def connect():
    try:
        password = get_secret()
        if password is None:
            print("Failed to retrieve password from AWS Secrets Manager")
            return False

        print("Starting DB connection")

        session = psycopg2.connect(
            dbname='fern-rds-db-instance',
            user='fern_admin',
            password=password,
            host='<RDS endpoint>',
            port='5432'
        )
        print("DB connection established")
        session.close()
        print("DB connection closed")
        return True

    except Exception as e:
        print(f"DB connection failed: {e}")
        return False

@app.route('/db-connection', methods=['GET'])
def db_connection():
    if connect():
        return "DB connection successful", 200
    else:
        return "DB connection failed", 500

if __name__ == '__main__':
    app.run(debug=True) #debug allows for auto run and reload of the server