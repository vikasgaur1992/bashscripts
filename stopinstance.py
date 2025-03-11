import boto3
import smtplib
from email.mime.text import MIMEText

# AWS Region
aws_region = "us-east-2"

# SMTP Parameters
smtp_server = "mailid"
smtp_port = 25
sender_email = "StoppedServer"

# Application_ID values to filter
application_ids = ["abc", "def", "App3"]  # Add multiple Application_ID values

# Initialize boto3 client
ec2 = boto3.client('ec2', region_name=aws_region)

# Fetch running instances with matching Application_ID tags
instances = ec2.describe_instances(
    Filters=[
        {'Name': 'instance-state-name', 'Values': ['running']},
        {'Name': 'tag:Application_ID', 'Values': application_ids}
    ]
)

# Collect instance details and stop instances
stopped_instances = []
instance_ids_to_stop = []

for reservation in instances['Reservations']:
    for instance in reservation['Instances']:
        instance_id = instance['InstanceId']
        instance_type = instance['InstanceType']
        private_ip = instance.get('PrivateIpAddress', 'N/A')
        public_ip = instance.get('PublicIpAddress', 'N/A')
        name = next((tag['Value'] for tag in instance.get('Tags', []) if tag['Key'] == 'Name'), 'N/A')

        stopped_instances.append([instance_id, instance_type, private_ip, public_ip, name])
        instance_ids_to_stop.append(instance_id)

# Stop instances
if instance_ids_to_stop:
    ec2.stop_instances(InstanceIds=instance_ids_to_stop)

# Prepare email content
if stopped_instances:
    email_body = "The following EC2 instances have been stopped in region us-east-2:\n\n"
    email_body += "InstanceId     InstanceType     PrivateIp     PublicIp     Name\n"
    email_body += "-------------------------------------------------------------\n"
    email_body += "\n".join(str(item) for item in stopped_instances)

    # Send email using mailx command
    cmd = f'echo "{email_body}" | mailx -r "{sender_email}" -s "Servers Stopped in DR Region" email_id'
    subprocess.run(cmd, shell=True)

print("Instances stopped and email notification sent.")
