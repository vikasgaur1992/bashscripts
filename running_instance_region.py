#Python script to send email with list of instance in a particular region
import boto3

import smtplib

import subprocess

from email.mime.text import MIMEText

# Parameters

aws_region = "us-east-1"

smtp_server = "smtprelay_server"

smpt_port = 25

# Initialize boto3 client

ec2 = boto3.client('ec2', region_name=aws_region)

# Fetch running instances

instances = ec2.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])

# Process instance details

instance_details = []

for reservation in instances['Reservations']:

    for instance in reservation['Instances']:

        instance_id = instance['InstanceId']

        instance_type = instance['InstanceType']

        private_ip = instance.get('PrivateIpAddress', 'N/A')

        public_ip = instance.get('PublicIpAddress', 'N/A')

        name = next((tag['Value'] for tag in instance.get('Tags', []) if tag['Key'] == 'Name'), 'N/A')

        a = [instance_id, instance_type, private_ip, public_ip, name]

        instance_details.append(a)

# Prepare email content

if instance_details:

    email_body = "The following EC2 instances are running in region us-east-2:\n\n"

    email_body += "InstanceId     InstanceType     PrivateIp     PublicIp     Name\n"

    email_body += "-------------------------------------------------------------\n"

    email_body += "\n".join(str(item) for item in instance_details)

cmd='echo "' + email_body + '" | mailx -r "RunningServer" -s "Server Running In DR Region" email_id'
