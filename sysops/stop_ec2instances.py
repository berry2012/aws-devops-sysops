import boto3
import os

profile = os.environ['AWS_PROFILE']
output = f"we are stopping instances using {profile} profile"
print(f"{output}\n")


# using shared aws credential
def stop_instances():
    session = boto3.Session(profile_name=profile)
    ec2 = session.client('ec2')
    response = ec2.stop_instances(
        InstanceIds=[
            'i-xxxxxxxxxxx',
            'i-xxxxxxxxxxx',
            'i-xxxxxxxxxxx'
        ],
        Force=True
    )
    print(response)


def get_instances():
    session = boto3.Session(profile_name=profile)
    ec2 = session.client('ec2')
    reservations = ec2.describe_instances(Filters=[
        {
            "Name": "instance-state-name",
            "Values": ["running", "stopped"],
        }
    ]).get("Reservations")

    for reservation in reservations:
        for instance in reservation["Instances"]:
            instance_id = instance["InstanceId"]
            instance_type = instance["InstanceType"]
            private_ip = instance["PrivateIpAddress"]
            instance_state = instance["State"]["Name"]
            instance_name = instance["Tags"][0]["Value"]
            print(f"{instance_id} {instance_type} {private_ip} {instance_state} {instance_name}")


print('==========================================Describing Instances before '
      'stopping=============================================')

get_instances()

print('==========================================Stopping Some Instances=============================================')

stop_instances()

print('==========================================Describing Instances=============================================')

get_instances()
