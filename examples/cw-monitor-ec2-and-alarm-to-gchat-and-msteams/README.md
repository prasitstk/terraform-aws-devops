# CloudWatch Monitoring EC2 instance and alarm to Google Chat and Microsoft Teams webhooks

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
gchat_card_img_alert_url   = "<public-url-of-image-for-alert-icon>"
gchat_card_img_ok_url      = "<public-url-of-image-for-ok-icon>"
ghat_webhook_url           = "https://chat.googleapis.com/xxx"
ghat_card_timezone         = "Asia/Bangkok"  # Can be changed
msteams_webhook_url        = "https://xxx.webhook.office.com/xxx"
msteams_card_timezone      = "Asia/Bangkok"  # Can be changed
cpu_alarm_threshold        = 75  # Can be changed
mem_alarm_threshold        = 75  # Can be changed
disk_alarm_threshold       = 75  # Can be changed
```

> NOTE: You can create and get `ghat_webhook_url` only when you have a Google Account user in Google Workspace of your organization.

> NOTE: You can create and get `msteams_webhook_url` only when you have a Microsoft Teams user in your organization.

Initialize the project, plan, and apply the resource changes with the local state file by:

```sh
terraform init
terraform plan -out /tmp/tfplan
terraform apply /tmp/tfplan
```

---

&nbsp;

## Verification

After finish `terraform apply /tmp/tfplan`, please wait until all cpu/memory/disk alarms publish messages to Google Chat and Microsoft Teams webhooks from `INSUFFICIENT_DATA` state to `OK` state.

Edit `terraform.tfvars` by changing `cpu_alarm_threshold`, `mem_alarm_threshold` and `disk_alarm_threshold` to be very low values such that alarms occur, for example:

```
cpu_alarm_threshold  = 0.1
mem_alarm_threshold  = 5
disk_alarm_threshold = 0.1
```

Then verify whether cpu/memory/disk alarms publish messages to Google Chat and Microsoft Teams webhooks from `OK` state to `ALARM` state.

Next, try to edit `terraform.tfvars` again back to normal as follows:
```
cpu_alarm_threshold  = 75
mem_alarm_threshold  = 75
disk_alarm_threshold = 75
```

Finally,  verify whether cpu/memory/disk alarms publish messages to Google Chat and Microsoft Teams webhooks from `ALARM` state back to `OK` state.

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

- [Are incoming webhooks available to all Google chat users or just users with Google Workspace access?](https://stackoverflow.com/questions/71013129/are-incoming-webhooks-available-to-all-google-chat-users-or-just-users-with-goog)
- [Send messages to Google Chat with incoming webhooks](https://developers.google.com/chat/how-tos/webhooks)

---
