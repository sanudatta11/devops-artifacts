import boto3
import sys
import json
import re
import time
client = boto3.client('ec2')


def lambda_handler(event,context):
    time.sleep(40)
    response = client.describe_instances(Filters=[
        {
            'Name': 'instance-state-code',
            'Values': [
                '16'
            ]
        },
    ],
    )

    idBatch = []
    for r in response['Reservations']:
        for i in r['Instances']:
            # print i['InstanceId']
            # print i['InstanceId']
            # print i['State']
            # print i['SecurityGroups'][0]['GroupName']
            # for key, value in i.iteritems() :
            #     print key
            if re.match(r"^(launch-wizard-)[0-9]+$", i['SecurityGroups'][0]['GroupName']):
                idBatch.append(str(i['InstanceId']))

            
    if len(idBatch) > 0:
        response = client.stop_instances(
                InstanceIds=idBatch,
            )
        return json.dumps(response)
