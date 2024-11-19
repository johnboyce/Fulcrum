import boto3
import json
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table_name = "FulcrumTable-us-west-2"
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    body = json.loads(event['body'])
    item_number = body['itemNumber']
    status = body['status']
    description = body['description']
    timestamp = int(datetime.utcnow().timestamp())

    table.put_item(Item={
        'itemNumber': item_number,
        'timestamp': timestamp,
        'status': status,
        'description': description
    })

    return {
        'statusCode': 200,
        'body': json.dumps({"message": "Item added successfully!"})
    }
