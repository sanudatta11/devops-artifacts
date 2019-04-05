import boto3
ec2 = boto3.resource('ec2')
ec2client = boto3.client('ec2')


def configure_update(config_type, event, session_attributes, slots):
    content = "Which Instance do you want to terminate? \n"
    if config_type.lower() == 'create':
        instance = ec2.create_instances(
            ImageId='ami-0de53d8956e8dcf80',
            MinCount=1,
            MaxCount=1,
            InstanceType='t2.micro',
            KeyName='TG')
        print(instance)
        print("Instance created with id {0}".format(instance[0].id))
        return {
            "dialogAction": {
                "type": "Close",
                "fulfillmentState": "Fulfilled",
                "message": {
                    "contentType": "PlainText",
                    "content": (
                        "Thanks, I have started the instance "
                        "with Id {0}."
                    ).format(instance[0].id)
                }
            }
        }
    # elif config_type.lower() == 'terminate':
    #     counter = 0
    #     response = ec2client.describe_instances(Filters=[
    #         {
    #             'Name': 'instance-state-code',
    #             'Values': [
    #                 '16',
    #             ]
    #         },
    #     ])
    #     for reservation in response["Reservations"]:
    #         for instance in reservation["Instances"]:
    #             counter = counter + 1
    #             i_id = instance["InstanceId"]
    #             print(instance)
    #             print(i_id)
    #             content = content + str(counter) + ". " + i_id + " "
    #     print(content)
    #     return {
    #         'sessionAttributes': session_attributes,
    #         'dialogAction': {
    #             'type': 'ElicitSlot',
    #             'intentName': event['currentIntent']['name'],
    #             'slots': [slots],
    #             'slotToElicit': 'terminateSlot',
    #             'message': {'contentType': 'PlainText', 'content': content}
    #         }
    #     }


def terminateInstance(term_type, event, session_attributes, slots):
    content = ""
    response = ec2client.describe_instances(Filters=[
        {
            'Name': 'instance-state-code',
            'Values': [
                    '16',
            ]
        },
    ])
    i_ids = []
    for reservation in response["Reservations"]:
            for instance in reservation["Instances"]:
                i_ids.append(instance["InstanceId"])
    ids = [i_ids[int(term_type)-1]]
    ec2.instances.filter(InstanceIds=ids).terminate()
    return {
        "dialogAction": {
            "type": "Close",
            "fulfillmentState": "Fulfilled",
            "message": {
                "contentType": "PlainText",
                "content": (
                    "Thanks, I have started the terminate "
                    "procedures for {0} Instance."
                ).format(ids[0])
            }
        }
    }
