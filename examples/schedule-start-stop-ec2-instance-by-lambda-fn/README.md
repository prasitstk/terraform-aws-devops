# Schedule start/stop an EC2 instance by a Lambda function

&nbsp;

## Prerequisites

- An active AWS account with an IAM user that has required permissions to create/update/delete resources.
- Access key of the IAM User
- Terraform (version >= 0.13)

---

&nbsp;

## Tasks

Create `terraform.tfvars` to define variables for Terraform as follows:

```
aws_region                 = "<your-aws-region>"
aws_access_key             = "<your-aws-access-key>"
aws_secret_key             = "<your-aws-secret-key>"
sys_name                   = "devops"  # Can be changed
sys_vpc_cidr_block         = "10.0.0.0/16"  # Can be changed
app_ami_id                 = "<ami-xxx>"
app_name                   = "app"  # Can be changed
app_az_name                = "<aws-az-for-app>"
app_fn_schedule_dry_run    = false  # Can be changed
app_fn_schedule_expression = "cron(*/5 * * * ? *)"  # Can be changed
app_fn_start_schedules     = ["0255", "0305"]  # Can be changed
app_fn_stop_schedules      = ["0250", "0300"]  # Can be changed
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

Specify when to start and stop the running EC2 instance created from this Terraform project in `terraform.tfvars`.
For example, to start and stop the instance by:
- Stop#1  > at 02:50
- Start#1 > at 02:55
- Stop#2  > at 03:00
- Start#2 > at 03:05

First, you need to specify the schedule to run every 5 minutes to the variable `app_fn_schedule_expression` as follows:
```
app_fn_schedule_expression = cron(*/5 * * * ? *)
```

Then, specify the schedule times to the variables `app_fn_start_schedules` and `app_fn_stop_schedules` as follows:
```
app_fn_start_schedules = ["0255", "0305"]
app_fn_stop_schedules  = ["0250", "0300"]
```

After apply the changes to the Terraform stack, the schedule will be triggered (every 5 minutes) and
it will invoke the Lambda function to check whether the invoked time is one of the specified times on `app_fn_start_schedules` or `app_fn_stop_schedules`.
If it is true, it will start or stop action based on that current invoked time.

---

&nbsp;

## Clean up

To clean up the whole stack by deleting all of the resources, run the following command:

```sh
terraform destroy
```

---
