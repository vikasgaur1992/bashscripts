'''
Script for adding/updating/deleting Ec2 tag
Steps :

1)copy private ips list inside instancelist.txt file
2)Execute
python addec2tag.py tagname tagvalue

*to delete tag pass "" as tagvalue
Eg :
1)add tag
python addec2tag Schedule Cecl-mon-fri-5am-6pm
2)remove tag
python addec2tag Schedule ""

'''



import boto3
import sys
ec2_client = boto3.client('ec2')
instanceids=[]


#getting resource id from private ip
def getinstanceid(private_ip):
	response = ec2_client.describe_instances(
			Filters=[{
				'Name': 'network-interface.addresses.private-ip-address',
				'Values': [private_ip]
			}]
		)
	instance_id = response['Reservations'][0]['Instances'][0]['InstanceId']
	instanceids.append(instance_id)

#adding/updating/deleting ec2tag    
def addtag(key,value):   
    infile=open("instancelist.txt", "r").read().splitlines()
    for privateip in infile:

        getinstanceid(privateip.strip())

    print(instanceids)


    response = ec2_client.create_tags(
        Resources=instanceids,
        Tags=[
            {
                'Key': key,
                'Value': value,
            },
        ],
    )
    print("Updated tag successfully for " + str(instanceids))
    print(key,value)



#ensuring required arguments are passed
if len(sys.argv)==3:
    key=sys.argv[1]
    value=sys.argv[2]
    addtag(key,value)
    
else :
    print("please pass the required tagname and value details.")
