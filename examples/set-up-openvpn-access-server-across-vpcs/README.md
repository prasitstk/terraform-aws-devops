# Set up OpenVPN Access Server across VPCs

&nbsp;

## Prerequisites

- An active AWS account with an IAM user that has required permissions to create/update/delete resources
- Access key of the IAM User
- Terraform (version >= 0.13)
- Subscribe to AWS Marketplace AMIs > OpenVPN Access Server
- OpenVPN Connect client program for your OS

---

&nbsp;

## Tasks

Create `terraform.tfvars` to define variables for Terraform as follows:

```
aws_region                  = "<your-aws-region>"
aws_access_key              = "<your-aws-access-key>"
aws_secret_key              = "<your-aws-secret-key>"
sys_name                    = "devops"                 # Can be changed
sys_vpn_vpc_cidr_block      = "192.168.0.0/16"         # Can be changed
sys_internal_vpc_cidr_block = "10.0.0.0/16"            # Can be changed
host_az_name                = "ap-southeast-1a"        # Can be changed
linux_host_ami_id           = "ami-005835d578c62050d"  # Can be changed
win_host_ami_id             = "ami-02d23a284394d70a0"  # Can be changed
openvpn_host_ami_id         = "ami-03e2781e8f0ee0d66"  # Can be changed
```

Initialize the project, plan, and apply the resource changes with the local state file by:
```sh
terraform init
terraform plan -out /tmp/tfplan
terraform apply /tmp/tfplan
```

&nbsp;

After applying the changes, generate the private key file by:
```sh
terraform output -raw sys_key_pair_private_key_pem > /path/to/sys_key_pair_private_key.pem
chmod 400 /path/to/sys_key_pair_private_key.pem
```

&nbsp;

Use the generated pem file to access to the OpenVPN host by:
```sh
ssh -i /path/to/sys_key_pair_private_key.pem openvpnas@<openvpn_host_eip>
```

> NOTE: You can get the <openvpn_host_eip> public IP from the output displayed after `terraform apply` or just type `terraform output openvpn_host_eip`.

&nbsp;

Once you get into the OpenVPN instance, there will be a wizard steps to help intially set up an OpenVPN admin user and other basic configuration. You can answer the questions as below as an example:

```sh
...

Please enter 'yes' to indicate your agreement [no]: yes

...

Will this be the primary Access Server node?
(enter 'no' to configure as a backup or standby node)
> Press ENTER for default [yes]: yes

Please specify the network interface and IP address to be
used by the Admin Web UI:
(1) all interfaces: 0.0.0.0
(2) ens5: 192.168.22.89
Please enter the option number from the list above (1-2).
> Press Enter for default [2]: 1

Please specify the port number for the Admin Web UI.
> Press ENTER for default [943]:

Please specify the TCP port number for the OpenVPN Daemon
> Press ENTER for default [443]:

Should client traffic be routed by default through the VPN?
> Press ENTER for default [no]:

Should client DNS traffic be routed by default through the VPN?
> Press ENTER for default [no]:

Use local authentication via internal DB?
> Press ENTER for default [yes]:

Private subnets detected: ['192.168.0.0/16']

Should private subnets be accessible to clients by default?
> Press ENTER for EC2 default [yes]:

Do you wish to login to the Admin UI as "openvpn"?
> Press ENTER for default [yes]:

> Please specify your OpenVPN-AS license key (or leave blank to specify later):


Initializing OpenVPN...

...
...

Initial Configuration Complete!

You can now continue configuring OpenVPN Access Server by
directing your Web browser to this URL:

https://18.142.132.42:943/admin
Login as "openvpn" with the same password used to authenticate
to this UNIX host.

During normal operation, OpenVPN AS can be accessed via these URLs:
Admin  UI: https://18.142.132.42:943/admin
Client UI: https://18.142.132.42:943/

See the Release Notes for this release at:
   https://openvpn.net/vpn-server-resources/release-notes/

```

> NOTE: `18.142.132.42` wa just an example of <openvpn_host_eip> Elastic public IP from my previous experiment.

&nbsp;

Then you should change the password of `openvpn` admin user to tne new one with `sudo passwd openvpn` and follow its instruction.

&nbsp;

Now the OpenVPN server should be ready. Open your browser and go to the OpenVPN admin page at `https://<openvpn_host_eip>:943/admin`. Sign in with `openvpn` user with the new password and go to the following pages from the left menu:

- `User Permissions` > Add a new OpenVPN user as a client `john`, for example, with manually setting up its password and others are default > Press `Save Settings` button > Press `Update Running Server` button.

- `VPN Settings` > `VPN IP Network` > `Routing` > Add `10.0.0.0/16` CIDR block (`local.sys_internal_vpc_cidr_block`) into a new line to the textbox of `Specify the private subnets to which all clients should be given access (one per line):` > Press `Save Settings` button > Press `Update Running Server` button.

&nbsp;

Log out from OpenVPN admin page. Go to the OpenVPN page for clients instead at `https://<openvpn_host_eip>:943`. Sign in with the new user `john` to download your profile file (.ovpn file). On the client web page, you can also download and install OpenVPN Connect client application for your platform here.

To verify that you can connect to the Windows and Linux hosts though OpenVPN, do the following steps:

1. Start `OpenVPN Connect` client application and add a new profile with the downloaded .ovpn file above and press `Connect` button with the password of the user from that profile to start the session.

2. To connect to the Windows host:
    - Go to EC2 console, select the launched instance of the Windows host, press `Connect` button, select `RDP client` tab, and press `Get password` button to use the private key file `/path/to/sys_key_pair_private_key.pem` to retrive the password of `Administrator` user of the Windows host.
    - Run `terraform output win_host_private_ip` to get the private IP of the Windows hosts: <win_host_private_ip>
    - Start the `Remote Desktop` application on your platform, create a new profile to connect to the <win_host_private_ip> private IP of that Windows host.
    - Sign in with `Administrator` user and the password that retrived from the previous step.
    - Now you should access to the Windows host with its private ip through OpenVPN session.
  
3. To connect to the Linux host:
    - Run `terraform output linux_host_private_ip` to get the private IP of the Linux hosts: <linux_host_private_ip>
    - Run `ssh -i ~/.ssh/sys_key_pair_private_key.pem ec2-user@<linux_host_private_ip>`.
    - Now you should access to the Linux host with its private ip (<linux_host_private_ip>) through OpenVPN session.

&nbsp;

You can refresh your state file by:
```sh
terraform refresh
```

&nbsp;

Finally, you can clean up all resources from your AWS account without any errors by:
```sh
terraform destroy
```

---

## Troubleshooting

You may get the error message below after running `terraform plan -out /tmp/tfplan`.

```
╷
│ Error: creating EC2 Instance: OptInRequired: In order to use this AWS Marketplace product you need to accept terms and subscribe. To do so please visit https://aws.amazon.com/marketplace/pp?sku=f2ew2wrz425a1jagnifd02u5t
│       status code: 401, request id: 0b522f44-c0f0-4519-9518-14e67a6f3cad
│ 
│   with aws_instance.openvpn_host_i,
│   on main.tf line 325, in resource "aws_instance" "openvpn_host_i":
│  325: resource "aws_instance" "openvpn_host_i" {
│ 
╵

```

This is because OpenVPN Access Server AMI requires us to subscibe to it.

Go to [the link of the AWS marketplace above](https://aws.amazon.com/marketplace/pp?sku=f2ew2wrz425a1jagnifd02u5t), 
subscribe the AMI, and accept its terms.

Then rerun `terraform plan -out /tmp/tfplan` and it should be find.

Note that these steps of subscription to a specific AMI should be only required once per an AWS account.

---

&nbsp;

## References

- [Setting up OpenVPN Access Server in Amazon VPC](https://aws.amazon.com/blogs/awsmarketplace/setting-up-openvpn-access-server-in-amazon-vpc/)
- [OpenVPN - Amazon Web Services EC2 BYOL appliance quick start guide](https://openvpn.net/vpn-server-resources/amazon-web-services-ec2-byol-appliance-quick-start-guide/)

---
