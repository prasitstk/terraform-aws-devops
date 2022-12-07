# Schedule to stop an RDS database instance by a Lambda function

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
data_db_name               = "test_db"  # Can be changed
data_master_db_user        = "test_user"  # Can be changed
data_master_db_password    = "<randomly-generated-manually>"
app_fn_schedule_dry_run    = false  # Can be changed
app_fn_schedule_expression = "cron(0 0 * * ? *)"  # Can be changed
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

Specify when to stop the running RDS database instance created from this Terraform project in `terraform.tfvars` using [the schedule Amazon EventBridge rule](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-create-rule-schedule.html), for example:
```
app_fn_schedule_expression = "cron(0 0 * * ? *)"
```

From the setting above, after we apply the changes to the Terraform stack, the schedule will be triggered daily 00:00 (UTC) and
it will invoke the Lambda function to stop the database instance.

---

&nbsp;

## Clean up

To clean up the whole stack by deleting all of the resources, run the following command:

```sh
terraform destroy
```

---

&nbsp;

## References

- [4 Steps to Create an AWS Lambda Function to Stop an RDS Instance](https://dbseer.com/4-steps-create-aws-lambda-function-stop-rds-instance/)
- [Field Notes: Stopping an Automatically Started Database Instance with Amazon RDS](https://aws.amazon.com/blogs/architecture/field-notes-stopping-an-automatically-started-database-instance-with-amazon-rds/)
- [Automatically Start/Stop an AWS RDS SQL Server using AWS Lambda functions](https://www.sqlshack.com/automatically-start-stop-an-aws-rds-sql-server-using-aws-lambda-functions/)
- [Schedule Amazon RDS stop and start using AWS Lambda](https://aws.amazon.com/blogs/database/schedule-amazon-rds-stop-and-start-using-aws-lambda/)

---
