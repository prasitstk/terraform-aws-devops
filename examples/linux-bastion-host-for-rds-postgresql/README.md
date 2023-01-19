# Set up Linux bastion host on AWS to connect to RDS PostgreSQL database using Terraform

&nbsp;

## Prerequisites

- An active AWS account with an IAM user that has required permissions to create/update/delete resources
- Access key of the IAM User
- Terraform (version >= 0.13)

---

&nbsp;

## Tasks

Create `terraform.tfvars` to define variables for Terraform as follows:

```
aws_region           = "<your-aws-region>"
aws_access_key       = "<your-aws-access-key>"
aws_secret_key       = "<your-aws-secret-key>"
sys_name             = "devops"                 # Can be changed
sys_vpc_cidr_block   = "10.0.0.0/16"            # Can be changed
db_name              = "test_db"                # Can be changed
master_db_user       = "test_db_user"           # Can be changed
master_db_password   = "<master_db_password>"   # Can be generated manually by `pwgen 20 1` for example.
bastion_host_az_name = "ap-southeast-1a"        # Can be changed
bastion_host_ami_id  = "ami-0af2f764c580cc1f9"  # Can be changed
```

Initialize the project, plan, and apply the resource changes with the local state file by:
```sh
terraform init
terraform plan -out /tmp/tfplan
terraform apply /tmp/tfplan
```

After applying the plan, it will show the output as follows:
```
bastion_host_key_pair_private_key_pem = <sensitive>
bastion_host_public_dns = "<EC2 public DNS of the bastion host>"
db_host = "<RDS database host name>"
db_name = "<The specified database name in locals>"
db_password = <sensitive>
db_port = 5432
db_username = "<The specified database username in locals>"
```

To show the `db_password` information, run `terraform output db_username`.

> NOTE: After applying the changes, the local file `terraform.tfstate` will be created.

Verify the result by:
1. Run `terraform output -raw bastion_host_key_pair_private_key_pem > /path/to/test_bastion_host.pem` to generate the pem file (private) key to access to the EC2 bastion host using SSH Tunnel.
2. Run `chmod 400 /path/to/test_bastion_host.pem` to the private key file to prevent the key from being publicly viewable and ssh command also requires it.
3. Open your Database client application like DBeaver > Create a new connection to PostgreSQL with the following information:
  - Main tab
    - Host: <db_host from the output above>
    - Port: <db_port from the output above>
    - Database: <db_name from the output above>
    - Username: <db_username from the output above>
    - Password: <db_password from the output above>
  - SSH tab
    - Use SSH Tunnel = True
    - Host/IP: <bastion_host_public_dns from the output above>
    - User Name: ec2-user
    - Authentication Method: Public Key
    - Private key: /path/to/test_bastion_host.pem
  - Press `Test Connection...` button
  - Press `Finish` button
4. Now you should see the test_db database to work with.

You can refresh your state file by:
```sh
terraform refresh
```

Finally, you can clean up all resources from your AWS account without any errors by:
```sh
terraform destroy
```

---

&nbsp;

## References

- [How to remove Terraform double quotes?](https://stackoverflow.com/questions/66935287/how-to-remove-terraform-double-quotes)
- [How to Setup Bastion Server with AWS EC2](https://medium.com/codex/how-to-setup-bastion-server-with-aws-ec2-b1590d2ff815)

---
