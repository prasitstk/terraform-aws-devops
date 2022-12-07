# Schedule to delete AMIs by tag "Name" using a Lambda function

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
aws_region                     = "<your-aws-region>"
aws_access_key                 = "<your-aws-access-key>"
aws_secret_key                 = "<your-aws-secret-key>"
sys_name                       = "devops"  # Can be changed
app_fn_schedule_expression     = "cron(0 0 * * ? *)"  # Can be changed
app_fn_schedule_dry_run        = false  # Can be changed
app_fn_schedule_tag_name       = "test-tag-ami"  # Can be changed
app_fn_schedule_retention_days = 7  # Can be changed
app_fn_schedule_min_retention  = 10 # Can be changed
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

Specify when to delete AMIs created from this Terraform project in `terraform.tfvars` using [the schedule Amazon EventBridge rule](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-create-rule-schedule.html), for example:
```
app_fn_schedule_expression = "cron(0 0 * * ? *)"
```

Specify AMI tag "Name" value of AMIs to be deleted, for example: 
```
app_fn_schedule_tag_name = "test-tag-ami"
```

Based on the AMI creation date, specify the number of days for those selected AMIs by tag "Name" to be retained, for example:
```
app_fn_schedule_retention_days = 7
```

However, you can specify the minimum of those AMIs to be retained. 
Note that this setting will override `app_fn_schedule_retention_days`, so that even if some AMI creation date of AMIs is older than `app_fn_schedule_retention_days` backed days,
those AMIs will be still retained because the number of AMIs will be less than `app_fn_schedule_min_retention` if they are deleted. 
For example, to retain at least 7 AMIs of a particular tag "Name" value, you can set `app_fn_schedule_min_retention` by:
```
app_fn_schedule_min_retention = 10
```

From the setting above, after we apply the changes to the Terraform stack, the schedule will be triggered daily 00:00 (UTC) and
it will invoke the Lambda function to delete AMIs based on tag "Name" value and their creation date.

---

&nbsp;

## Clean up

To clean up the whole stack by deleting all of the resources, run the following command:

```sh
terraform destroy
```

---
