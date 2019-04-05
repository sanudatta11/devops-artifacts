from messages import detailed_message, alert_help_message
import boto3
ec2 = boto3.resource('ec2')
ec2client = boto3.client('ec2')


def validate(event, context):
    print('validation event')
    print(event)
    if event['sessionAttributes'] is not None:
        session_attributes = event['sessionAttributes']
    else:
        session_attributes = {}
    slots = event['currentIntent']['slots']
    instance_slot = slots['instanceSlot'] or ''
    term_slot = slots['terminateSlot'] or ''
    print(instance_slot, term_slot)
    print(type(term_slot))
    print(term_slot in ["1"])
    if instance_slot.lower() == 'help':
        print('Help Invoked')
        return {
            'sessionAttributes': session_attributes,
            'dialogAction': {
                'type': 'ElicitSlot',
                'intentName': event['currentIntent']['name'],
                'slots': slots,
                'slotToElicit': 'instanceSlot',
                'message': {'contentType': 'PlainText', 'content': detailed_message}
            }
        }
    elif (instance_slot.lower() not in ['create', 'info', 'terminate', 'stop']) and (term_slot not in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]):
        print('NOT IN CHOICES')
        return {
            'sessionAttributes': session_attributes,
            'dialogAction': {
                'type': 'ElicitSlot',
                'intentName': event['currentIntent']['name'],
                'slots': slots,
                'slotToElicit': 'instanceSlot',
                'message': {'contentType': 'PlainText', 'content': 'Please select between only four instance options (Create,Stop,Info,Terminate)'}
            }
        }
    elif term_slot in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]:
        print('RETURN DELEGATE')
        return {
            'sessionAttributes': session_attributes,
            'dialogAction': {
                'type': 'Delegate',
                'slots': slots
            }
        }
    elif instance_slot.lower() == 'terminate':
        counter = 0
        content = "Which instance you wanna terminate?\n"
        response = ec2client.describe_instances(Filters=[
            {
                'Name': 'instance-state-code',
                'Values': [
                    '16',
                ]
            },
        ])
        for reservation in response["Reservations"]:
            for instance in reservation["Instances"]:
                counter = counter + 1
                i_id = instance["InstanceId"]
                print(instance)
                print(i_id)
                content = content + str(counter) + ". " + i_id + "\n"
        print(content)
        return {
            'sessionAttributes': session_attributes,
            'dialogAction': {
                'type': 'ElicitSlot',
                'intentName': event['currentIntent']['name'],
                'slots': slots,
                'slotToElicit': 'terminateSlot',
                'message': {'contentType': 'PlainText', 'content': content}
            }
        }
    else:
        print('RETURN DELEGATE')
        return {
            'sessionAttributes': session_attributes,
            'dialogAction': {
                'type': 'Delegate',
                'slots': slots
            }
        }
