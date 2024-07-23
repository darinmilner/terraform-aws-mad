import boto3 
import json

client = boto3.client("sqs")

def get_queue_url(): 
    response = client.get_queue_url(
        QueueName="notification-queue"
    )

    return response["QueueUrl"]

url = get_queue_url()
print(url)

def send_message():
    message = {
        "test-key-2": "test-value-2",
        "test1": "test-value"
    }
    response = client.send_message(
        QueueUrl=url,
        MessageBody=json.dumps(message)
    )

    print(response)

# send_message()

def get_message():
    response = client.receive_message(
        QueueUrl=url,
        MaxNumberOfMessages=5,
        WaitTimeSeconds=10
    )

    print(f"Number of messages received: {len(response.get('Messages', []))}")

    for message in response.get("Messages", []):
        msg = message["Body"]
        print(f"Message body: {json.loads(msg)}")
        print(f"Receipt Handle: {message['ReceiptHandle']}")

get_message()