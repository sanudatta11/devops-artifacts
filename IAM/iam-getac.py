import datetime
import dateutil
import boto
from dateutil import parser
from boto import iam
 
import boto3

# Boto 2 Code

conn=iam.connect_to_region('ap-southeast-1')
users=conn.get_all_users()
timeLimit=datetime.datetime.now() - datetime.timedelta(days=0)
 
# print "-------------------------------------------------------------"
# print "Access Keys Created Date" + "\t\t" + "Username"
# print "-------------------------------------------------------------"
 
# for user in users.list_users_response.users:
#     accessKeys=conn.get_all_access_keys(user_name=user['user_name'])
#     for keysCreatedDate in accessKeys.list_access_keys_response.list_access_keys_result.access_key_metadata:
#         if parser.parse(keysCreatedDate['create_date']).date() <= timeLimit.date():
#             print(keysCreatedDate['create_date']) + "\t\t" + user['user_name']


# Boto 3 Code

client = boto3.client('iam')

response = client.list_users()

# print(response)

counter = 0
print "-----------------------------------------------------------------------------------------------------------------------------------------------------"
print "Access Keys Created Date" +"\t\t" + "Access Key"  + "\t\t\t" + "Username" + "\t\t" + "Region" + "\t\t" + "Service" + "\t\t" + "LastUsed"
print "-----------------------------------------------------------------------------------------------------------------------------------------------------"
 
for user in response['Users']:
        try:
            username = user['UserName']
            acc_keys = client.list_access_keys(
                UserName = username
            )
            akey = acc_keys['AccessKeyMetadata'][0]['AccessKeyId']
            adate = acc_keys['AccessKeyMetadata'][0]['CreateDate']
            status = acc_keys['AccessKeyMetadata'][0]['Status']            
            resp1 = client.get_access_key_last_used(AccessKeyId=akey)
            acc_key_use_data = resp1['AccessKeyLastUsed']
            # print(adate,akey,username,status)
            truncA = ""
            if(len(username) > 8):
                truncA = "*"
            print str(adate) + "\t\t"+ akey +"\t\t" + username[:8] + truncA + "\t\t" + acc_key_use_data['Region'] + "\t\t" + acc_key_use_data['ServiceName'] + "\t\t" + str(acc_key_use_data['LastUsedDate'])
        except:
            print("No Access Key for user {0}".format(user['UserName']))
        # print counter
        
        # print resp1
        # rep = client.generate_service_last_accessed_details(Arn=user['Arn'])
        # rep2 = client.get_service_last_accessed_details(JobId=rep['JobId'])
        # print rep2
        # print "--------------------------------------------------- END -----------------------------------------------------------"

# response = client.list_access_keys()

# for user in response['Users']:
#     print(user)
# print(response)

