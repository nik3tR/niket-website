import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('niketrathod.com_visitorCounter')

def lambda_handler(event, context):

    body = event.get('body')

    #if no body error
    if not body:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing request body"})
        }

    try:
        data = json.loads(body)
    except json.JSONDecodeError:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid JSON"})
        }

    try:
        response = table.update_item(
            Key={"counterId": "visitorCounter"},
            UpdateExpression="SET #count = #count + :val",
            ExpressionAttributeNames={"#count": "count"},
            ExpressionAttributeValues={":val": 1},
            ReturnValues="UPDATED_NEW"
        )
        new_count = int(response["Attributes"]["count"])
    
    except Exception as e:
        print(f"Error updating DynamoDB: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Internal server error"})
        }

    return {
        "statusCode": 200,
        "body": json.dumps({"count": new_count})
    }
