
# audit EC2 Run Instance events

aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=RunInstances AttributeKey=ResourceType,AttributeValue=AWS::EC2::Instance \
  --start-time "August 27, 2022, 00:00:00" \
  --end-time "August 27, 2022, 23:59:00" | jq '.Events [] | .CloudTrailEvent | fromjson | .responseElements | .instancesSet | .items | .[]? | {InstanceID: .instanceId, NodeName: .privateDnsName}'


