# ECS Fargate Scheduled Tasks to start SSM Run Command to perform its job on EC2 instances on a Resource group

&nbsp;

## Prerequisites

- An active AWS account with an IAM user that has required permissions to create/update/delete resources.
- Access key of the IAM User
- Terraform (version >= 0.13)
- AWS CLI
- Docker
- Git

---

&nbsp;

## Tasks

Configure AWS CLI by:

```sh
aws configure
# AWS Access Key ID [None]: <your-aws-access-key>
# AWS Secret Access Key [None]: <your-aws-secret-key>
# Default region name [None]: <your-aws-access-region>
# Default output format [None]: json
```

Create `terraform.tfvars` to define variables for Terraform as follows:

```
aws_region              = "<your-aws-region>"
aws_access_key          = "<your-aws-access-key>"
aws_secret_key          = "<your-aws-secret-key>"
sys_name                = "devops"  # Can be changed
sys_vpc_cidr_block      = "10.0.0.0/16"  # Can be changed
env_name                = "staging"  # Can be changed
ec2conn_cidr_block      = "<x.x.x.xx/x>"  # Should be that of the region as defined in aws_region
app_ami_id              = "<ami-xxx>"
app_img_repo_name       = "create-mock-file-job"  # Can be changed
app_img_tag             = "latest"
app_src_repo_url        = "https://github.com/prasitstk/create-mock-file-job.git"
app_mock_content        = "Test content"  # Can be changed
app_schedule_expression = "cron(0 0 * * ? *)"  # Can be changed (NOTE: It is in UTC)
app_command             = "/app/run-ssm-cmd-to-create-mock-file.sh"
app1_name               = "app1"  # Can be changed
app1_az_name            = "<aws-az-for-app1>"
app2_name               = "app2"  # Can be changed
app2_az_name            = "<aws-az-for-app1>"
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

Wait until the time that the ECS scheduled task is specified to be started. 
Then go to `ECS Console` > `Clusters` > `<your cluster>` > `Tasks` to make sure the task is started and stopped properly.

Go to `EC2 Console` and connect to app1 instance and app2 instance by `EC2 Instance Connect`, 
and then check whether there is `~/mock.txt` file is generated and its content is like `2022-12-03 22:23:58: Message = Test content`.

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

- [Environment variables to configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
- [How to remove entrypoint from parent Image on Dockerfile](https://stackoverflow.com/questions/40122152/how-to-remove-entrypoint-from-parent-image-on-dockerfile)
- [How to Override Entrypoint Using Docker Run](https://phoenixnap.com/kb/docker-run-override-entrypoint)
- [dockerhub :: amazon/aws-cli](https://hub.docker.com/r/amazon/aws-cli)
- [Running commands using a specific document version](https://docs.aws.amazon.com/systems-manager/latest/userguide/run-command-version.html)
- [AWS cron expression to run every other Monday](https://stackoverflow.com/questions/63059020/aws-cron-expression-to-run-every-other-monday)
- [Cron and rate expressions for maintenance windows](https://docs.aws.amazon.com/systems-manager/latest/userguide/reference-cron-and-rate-expressions.html#reference-cron-and-rate-expressions-maintenance-window)

---
