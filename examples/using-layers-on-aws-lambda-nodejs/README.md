# Using AWS Lambda Layers on AWS Lambda Function on Node.js 

&nbsp;

## Prerequisites

- An active AWS account with an IAM user that has required permissions to create/update/delete resources.
- Access key of the IAM User
- Terraform (version >= 0.13)
- Node.js 16.x runtime with NPM

---

&nbsp;

## Tasks

Create `terraform.tfvars` to define variables for Terraform as follows:

```
aws_region     = "<your-aws-region>"
aws_access_key = "<your-aws-access-key>"
aws_secret_key = "<your-aws-secret-key>"
sys_name       = "devops"  # Can be changed
fn_msg_name    = "Testing function message name"  # Can be changed
```

Initialize the project, plan, and apply the resource changes with the local state file by:

```sh
terraform init
terraform plan -out /tmp/tfplan
terraform apply /tmp/tfplan
```

---

&nbsp;

## Verification

Go to AWS Lambda Function console > Select the created example function > Create a mock test event > Click `Test` button.

Check whether the response on the Function console is successful and show the message body like:

```json
{
  "statusCode": 200,
  "body": "{\"getGreetingMsgWithNameFromUtil\":\"Hello! Testing function message name\",\"getGreetingMsgWithUUIDv4FromUtil\":\"Hello! a8a1eab6-e08f-4589-a29f-fef5fba05c51\",\"greetingMsgWithUUIDv4\":\"Hi! dbb3ca65-2ef5-4807-bfb7-b3de71b2c8ba\"}"
}
```

---

&nbsp;

## Clean up

To clean up the whole stack by deleting all of the resources, run the following command:

```sh
terraform destroy
```

---
