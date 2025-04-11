import json
import boto3
import uuid
import os

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

table = dynamodb.Table(os.environ['TABLE_NAME'])
bucket = os.environ['BUCKET_NAME']

def lambda_handler(event, context):
    body = json.loads(event['body'])
    item_id = str(uuid.uuid4())
    item = {"id": item_id, **body}

    # Salvar no DynamoDB
    table.put_item(Item=item)

    # Salvar no S3
    s3.put_object(
        Bucket=bucket,
        Key=f"{item_id}.json",
        Body=json.dumps(item)
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Item criado", "id": item_id})
    }
