# ECS Fargate Scheduled Tasks to dump RDS MySQL database into an S3 bucket

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
app_img_repo_name       = "mysqldump-to-s3-job"  # Can be changed
app_img_tag             = "latest"
app_src_repo_url        = "https://github.com/prasitstk/mysqldump-to-s3-job.git"
data_db_name            = "test_dump_db"  # Can be changed
data_master_db_user     = "test_user"  # Can be changed
data_master_db_password = "<randomly-generated-manually>"
data_bucket_name        = "<globally-unique-bucket-name>"
app_schedule_expression = "cron(0 0 * * ? *)"  # Can be changed (NOTE: It is in UTC)
app_command             = "/app/run-mysqldump-to-s3.sh"
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

Import `files/example-db.sql` SQL file into the provisioned `<data_db_name>` RDS MySQL database by using any of your database client.
You can get connection information by running `terraform output`.

Wait until the time that the ECS scheduled task is specified to be started. 
Then go to `ECS Console` > `Clusters` > `<your cluster>` > `Tasks` to make sure the task is started and stopped properly.

Check whether there is a database dump file in `s3://test-data-dump.prasitio.com/db-dumps/db-dump_<data_db_name>_<timestamp>-sql.gz`.
Download and extract it to check its correctness.

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

Sample database
- [MySQL Sample Database](https://www.mysqltutorial.org/mysql-sample-database.aspx)

ECR Authentication
- [Amazon ECR public registries](https://docs.aws.amazon.com/AmazonECR/latest/public/public-registries.html#public-registry-auth)
- [aws :: ecr :: get-login](https://docs.aws.amazon.com/cli/latest/reference/ecr/get-login.html)
- [aws-cli :: Quick setup](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html)

Run scheduled task on ECS Fargate
- [aws :: ecs :: Scheduled tasks](https://docs.aws.amazon.com/AmazonECS/latest/userguide/scheduled_tasks.html)
- [How to use AWS Fargate and Lambda for long-running processes in a Serverless app](https://www.serverless.com/blog/serverless-application-for-long-running-process-fargate-lambda/)
- [Using ECS tasks on AWS Fargate to replace Lambda functions](https://www.gravitywell.co.uk/insights/using-ecs-tasks-on-aws-fargate-to-replace-lambda-functions/)
- [Run tasks with AWS Fargate and Lambda](https://lobster1234.github.io/2017/12/03/run-tasks-with-aws-fargate-and-lambda/)
- [AWS cron expression to run every other Monday](https://stackoverflow.com/questions/63059020/aws-cron-expression-to-run-every-other-monday)

MySQL Dump using Docker container
- [spalladino/mysql-docker.sh](https://gist.github.com/spalladino/6d981f7b33f6e0afe6bb)
- [Backup and restore a mysql database from a running Docker mysql container](https://siriphonnot.medium.com/backup-and-restore-a-mysql-database-from-a-running-docker-mysql-container-6c932907e21f)
- [Database backups via mysqldump: from MariaDB container to S3](https://davidhamann.de/2022/05/13/mysqldump-docker-container-to-s3/)
- [MySQL Backup and Restore in Docker](https://medium.com/@tomsowerby/mysql-backup-and-restore-in-docker-fcc07137c757)
- [dockerhub :: mysql](https://hub.docker.com/_/mysql/)
- [Cannot conect MySQL (error 2026) after upgrade to Ubuntu 20.04](https://serverfault.com/questions/1016796/cannot-conect-mysql-error-2026-after-upgrade-to-ubuntu-20-04)
- [How to connect to the Docker host from inside a Docker container?](https://medium.com/@TimvanBaarsen/how-to-connect-to-the-docker-host-from-inside-a-docker-container-112b4c71bc66)
- [how to mysqldump remote db from local machine](https://stackoverflow.com/questions/2989724/how-to-mysqldump-remote-db-from-local-machine)
- [Docker MySQL Container: 3 Easy Steps for Setup and Configuration](https://hevodata.com/learn/docker-mysql/)
- [From inside of a Docker container, how do I connect to the localhost of the machine?](https://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach)

Installing AWS CLI with Dockers
- [Installing AWS CLI with Dockers](https://adityagoel123.medium.com/installing-aws-cli-sam-cli-inside-docker-ef91ceb4e250)

Run SSM Run command on ECS task on docker
- [Walkthrough: Use the AWS CLI with Run Command](https://docs.aws.amazon.com/systems-manager/latest/userguide/walkthrough-cli.html)

---
