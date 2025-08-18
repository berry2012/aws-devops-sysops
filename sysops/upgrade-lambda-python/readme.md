# Automated Migration Script for AWS Lambda Python 3.9 End-of-Support

For more information about this deprecation, read the [article](https://repost.aws/articles/ARRCAyrRH9TTGsKWasFzdbdw/automated-migration-script-for-aws-lambda-python-3-9-end-of-support)

## Prerequisites:

- Install and configure the latest version of the AWS Command Line Interface (AWS CLI).
- Python 3.x installed on your local machine
- Required [AWS SDK for Python (Boto3)](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html). You can install with `pip`.


## Dry run across multiple regions

```bash
python3 update_lambda_runtime.py --regions us-east-1 eu-west-1 --profile prod --dry-run
```

## Update with report generation

```bash
python3 update_lambda_runtime.py --regions us-east-1 --profile prod --report update_report.json
```

```bash
python3 update_lambda_runtime.py --regions us-east-1 eu-west-1 ap-southeast-1 eu-west-2 us-west-2 --profile staging --dry-run --report update_report.json
```

## Rollback functions

```bash
python3 update_lambda_runtime.py --regions us-east-1 --profile prod --rollback
```

## Multiple regions with dry run

```bash
python3 update_lambda_runtime.py --regions us-east-1 eu-west-1 ap-southeast-1 --dry-run
```
