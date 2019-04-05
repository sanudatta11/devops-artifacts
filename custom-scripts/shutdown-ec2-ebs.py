import boto3
import sys
import json
import re
import time

client = boto3.client('ec2')
ec2 = boto3.resource('ec2')

def lambda_handler(event,context):
    response = client.describe_instances(Filters=[
        {
            'Name': 'instance-state-code',
            'Values': [
                '0'
            ]
        },
    ],
    )

    volumeId = NULL
    for r in response['Reservations']:
        for i in r['Instances']:
            volumeId =  i['BlockDeviceMappings'][0]['Ebs']['VolumeId']

    
    volume = ec2.volumes.filter( Filters=[
        {
            'Name': 'volume-id',
            'Values': [
                volumeId,
            ]
        },
    ],)
    for a in volume.attachments:
        if(volume.encrypted == False or volume.encrypted == 'False'):
            idBatch.append(str(a['InstanceId']))
                    
    if len(idBatch) > 0:
        response = client.stop_instances(
                InstanceIds=idBatch,
            )
        return json.dumps(response)
