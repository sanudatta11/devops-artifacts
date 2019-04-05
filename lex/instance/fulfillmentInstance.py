import scripters


def handler(event, context):
    if event['sessionAttributes'] is not None:
        session_attributes = event['sessionAttributes']
    else:
        session_attributes = {}
    slots = event['currentIntent']['slots']

    print('fulfillment event:')
    print(event)
    config_type = event['currentIntent']['slots']['instanceSlot']
    term_type = event['currentIntent']['slots']['terminateSlot']
    print(config_type, term_type)

    if config_type is not None and term_type not in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]:
        alert_response = scripters.configure_update(
            config_type,  event, session_attributes, slots)
    elif term_type in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]:
        alert_response = scripters.terminateInstance(
            term_type, event, session_attributes, slots)
    return alert_response
