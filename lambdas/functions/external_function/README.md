# Tracking Worksheet: AWS Management Console

## Step 1: Information about the Lambda Function (remote service) *****
---
Your AWS Account ID: XXXXXXXXX
Lambda Function Name: ap-southeast-2-XXXXXXXXX-external-function

## Step 2: Information about the API Gateway (proxy Service) ********
---
New IAM Role Name: ap-southeast-2-XXXXXXXXX-external-function-proxy-role
New IAM Role ARN: arn:aws:iam::XXXXXXXXX:role/ap-southeast-2-XXXXXXXXX-external-function-proxy-role
Snowflake VPC ID (optional): ______________________________________________
New API Name: external-function-rest-api
API Gateway Resource Name: action
Resource Invocation URL: https://xxxxxxx.execute-api.ap-southeast-2.amazonaws.com/test
Method Request ARN: arn:aws:execute-api:ap-southeast-2:XXXXXXXXX:xxxxxx/*/POST/action

## Step 3: Information about the API Integration and External Function ***
---
API Integration Name: EXTERNAL_FUNCTION_API_INTEGRATION
API_AWS_IAM_USER_ARN: arn:aws:iam::xxxxxxxx:user/5tjb-s-xxxxx
API_AWS_EXTERNAL_ID: xxxxxxxxxx=2_OJ0KYyXr0dyGHS69gDmjRqY1s1E=
External Function Name: CURRENCY_EXCHANGE_FUNCTION


# Testing lambda
```
{
  "body":
    "{ \"data\": [ [ 0, 43, \"page\" ], [ 1, 42, \"life, the universe, and everything\" ] ] }"
}
```

# Invocation URL
```https://xxxxxxxxxxx.execute-api.ap-southeast-2.amazonaws.com/test/action```