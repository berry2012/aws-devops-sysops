import boto3
import os
import time

# deploy to AWS Lambda

region = 'eu-west-1'
instances = ['i-xxxxxxxxx',
            'i-xxxxxxxxxx'
]

ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
            def stop_instances():
                response = ec2.stop_instances(
                    InstanceIds=instances,
                    Force=True
                )
                print('stopped your instances: ' + str(instances))


            def get_instances():

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


            print ("Start : %s" % time.ctime())

            print('==========================================Describing Instances before '
                  'stopping=============================================\n')

            get_instances()

            print('==========================================Stopping Some Instances=============================================\n')

            stop_instances()

            time.sleep( 5 )
            print ("End : %s" % time.ctime())

            print('==========================================Describing Instances=============================================')

            get_instances()
