import boto3
import sys
import argparse
from collections import defaultdict
import json
from netaddr import IPNetwork

# Region Details
ap = argparse.ArgumentParser()
ap.add_argument('-r', '--region', help="region to deploy", required=True)
ap.add_argument('-v', '--vpc', help="VPC to deploy", required=True)
ap.add_argument('-a', '--az', help="AZ to deploy", required=True)
ap.add_argument('-s', '--subnet', help="Subnet to deploy", required=True)
args = vars(ap.parse_args())

region = args['region']
az = args['az']
vpc = args['vpc']
subnet = args['subnet']

ipinfo = []
cidr_block = 0
ec2 = boto3.resource('ec2')
client = boto3.client('ec2')

running_instances = ec2.instances.filter(Filters=[{
    'Name': 'instance-state-name',
    'Values': ['running']},{
        'Name': 'availability-zone',
        'Values': [az]
        },
        {
        'Name': 'vpc-id',
        'Values': [vpc]
        },
        {
        'Name': 'subnet-id',
        'Values': [subnet]
        }])

for instance in running_instances:
    for tag in instance.tags:
        if 'Name'in tag['Key']:
            name = tag['Value']
    ipinfo.append(instance.private_ip_address)

filters = [{'Name':'subnet-id', 'Values':[subnet]}]
subnets = list(ec2.subnets.filter(Filters=filters))

for subnet in subnets:
    response = client.describe_subnets(
        SubnetIds=[
            subnet.id,
        ]
    )
    cidr_block = response['Subnets'][0]['CidrBlock']

free_block=[]
for ip in IPNetwork(cidr_block):
    if str(ip) not in ipinfo:
        free_block.append(str(ip))

print "Free IPs : %d, using IP %s" % (len(free_block) , free_block[5] )

instance = ec2.create_instances(
    ImageId = 'ami-0de53d8956e8dcf80',
    MinCount = 1,
    MaxCount = 1,
    InstanceType = 't2.micro',
    KeyName = 'TG',
    PrivateIpAddress = free_block[5],
    SubnetId = str(args['subnet']))

print "Instance created with ID = %s" % str(instance[0].id)