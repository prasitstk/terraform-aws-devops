# Cloudfront Invalidation from Cross Account CodePipeline

&nbsp;

## Prerequisites

- An source AWS account with an IAM user that has required permissions to create/update/delete resources
- An target AWS account with an IAM user that has required permissions to create/update/delete resources
- Access key of the IAM User
- Terraform (version >= 0.13)
- Your S3 Static Website repository in a Git provider (BitBucket or GitHub)
- AWS CodeStar connection to your repository in [BitBucker](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-bitbucket.html) or [GitHub](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-github.html) that is already available.
- Your registered domain name (It can be outside Amazon Route 53)
- Amazon Route 53 hosted zone of your domain name

> NOTE:
> - The source AWS account is defined as the account of the website S3 bucket and its CodePipeline configuration.
> - The target AWS account is defined as the account of the invalidated CloudFront distribution, Route 53 hosted zone, and ACM certifications.

---

&nbsp;

## Tasks

Create `terraform.tfvars` to define variables for Terraform as follows:

```
src_aws_region              = "<source-aws-account-region>"
src_aws_access_key          = "<source-aws-account-access-key>"
src_aws_secret_key          = "<source-aws-account-secret-key>"
tgt_aws_region              = "<target-aws-account-region>"
tgt_aws_access_key          = "<target-aws-account-access-key>"
tgt_aws_secret_key          = "<target-aws-account-secret-key>"
sys_name                    = "tutorials"  # Can be changed
app_zone_name               = "<your-app-domain.com>"
app_domain_name             = "<app-sub-domain>.<your-app-domain.com>"
app_codestar_connection_arn = "arn:aws:codestar-connections:<your-aws-region>:<AWS-Account-ID>:connection/<...>"
app_full_repository_id      = "<your-full-repository-id>"  # for example: "prasitstk/react-crud-web-api"
app_branch_name             = "<your-branch>"  # for example: "master"
api_domain_name             = "<api-sub-domain>.<your-api-domain.com>"  # The api implmentation does not exist in this example
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

Print the output to get the App URL by:

```sh
terraform output
# ...
# app_live_url = "https://<app_domain_name>"
```

Verify the result by browsing to that URL from `app_live_url` output.

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

- [Cloudfront Invalidation from Cross Account CodePipeline](https://subhaspatil-c.medium.com/cloudfront-invalidation-from-cross-account-codepipeline-8614a8b858b1)
- [Cross-Account CloudFront Invalidation with CodePipeline, CDK + Python](https://python.plainenglish.io/cross-account-cloudfront-invalidation-with-codepipeline-cdk-python-d1f294ec72fc)
- [AWS: Creating a CloudFront Invalidation in CodePipeline using Lambda Actions](https://medium.com/fullstackai/aws-creating-a-cloudfront-invalidation-in-codepipeline-using-lambda-actions-49c1fd3a3c31)
- [Create CloudFront Invalidations in Cross AWS account](https://stackoverflow.com/questions/59929870/create-cloudfront-invalidations-in-cross-aws-account)

---
