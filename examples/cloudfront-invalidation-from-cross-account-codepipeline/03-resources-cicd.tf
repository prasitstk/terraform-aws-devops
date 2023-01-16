###################
# CI/CD resources #
###################

#---------------------------------#
# IAM resources :: Target account #
#---------------------------------#

resource "aws_iam_role" "cloudfront_assume_role_on_tgt_account_role" {
  provider = aws.target
  name     = "CloudfrontAssumeRoleFromSourceAccount"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.src.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/CloudFrontFullAccess"
  ]
}

#----------------------------------#
# SSM Parameters :: Source account #
#----------------------------------#

resource "aws_ssm_parameter" "codepipeline_app_website_s3_bucket" {
  provider = aws.source
  
  name  = "/codepipeline/${var.sys_name}-app/WEBSITE_S3_BUCKET"
  type  = "String"
  value = module.app_bucket.bucket.bucket
}

resource "aws_ssm_parameter" "codepipeline_app_cloudfront_dist_id" {
  provider = aws.source
  
  name  = "/codepipeline/${var.sys_name}-app/CLOUDFRONT_DIST_ID"
  type  = "String"
  value = aws_cloudfront_distribution.app_bucket_dist.id
}

resource "aws_ssm_parameter" "codepipeline_app_dotenv" {
  provider = aws.source
  
  name = "/codepipeline/${var.sys_name}-app/DOTENV"
  type = "String"
  value = templatefile("${path.module}/files/aws_ssm_parameter/codepipeline_app/dotenv.tftpl", {
    api_domain_name = var.api_domain_name
  })
}

#--------------------------------------#
# Function resources :: Source account #
#--------------------------------------#

resource "aws_iam_policy" "codepipeline_lambda_exec_policy" {
 provider = aws.source

  name = "CodePipelineLambdaExecPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:*"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "codepipeline:PutJobSuccessResult",
          "codepipeline:PutJobFailureResult"
        ],
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "codepipeline_cloudfront_invalidation_cross_account_fn_base_policy" {
  provider = aws.source

  name = "codepipeline-cloudfront-invalidation-cross-account-fn-base-policy"
  path = "/service-role/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:${var.src_aws_region}:${data.aws_caller_identity.src.account_id}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.src_aws_region}:${data.aws_caller_identity.src.account_id}:log-group:/aws/lambda/codepipeline-cloudfront-invalidation-cross-account-fn:*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "cloudfront_invalidation_on_tgt_account" {
  provider = aws.source

  name = "CloudfrontInvalidationOnTargetAccount"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Resource  = aws_iam_role.cloudfront_assume_role_on_tgt_account_role.arn
        Condition = {}
      }
    ]
  })
}

resource "aws_iam_role" "codepipeline_cloudfront_invalidation_cross_account_fn_role" {
  provider = aws.source

  name = "codepipeline-cloudfront-invalidation-cross-account-fn-role"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.codepipeline_cloudfront_invalidation_cross_account_fn_base_policy.arn,
    aws_iam_policy.codepipeline_lambda_exec_policy.arn,
    aws_iam_policy.cloudfront_invalidation_on_tgt_account.arn
  ]
}

resource "aws_lambda_function" "codepipeline_cloudfront_invalidation_cross_account_fn" {
  provider = aws.source

  function_name = "codepipeline-cloudfront-invalidation-cross-account-fn"

  package_type     = "Zip"
  publish          = false
  filename         = data.archive_file.codepipeline_cloudfront_invalidation_cross_account_fn_zip.output_path
  source_code_hash = data.archive_file.codepipeline_cloudfront_invalidation_cross_account_fn_zip.output_base64sha256

  role    = aws_iam_role.codepipeline_cloudfront_invalidation_cross_account_fn_role.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.9"

  timeout = 30

}

#---------------------------------------#
# CodeBuild resources :: Source account #
#---------------------------------------#

resource "aws_iam_policy" "app_bldproj_base_policy" {
  provider = aws.source
  
  name        = "CodeBuildBasePolicy-${var.sys_name}-app-bldproj-${var.src_aws_region}"
  description = "Policy used in trust relationship with CodeBuild"
  path        = "/service-role/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:${var.src_aws_region}:${data.aws_caller_identity.src.account_id}:log-group:/aws/codebuild/${var.sys_name}-app-bldproj",
          "arn:aws:logs:${var.src_aws_region}:${data.aws_caller_identity.src.account_id}:log-group:/aws/codebuild/${var.sys_name}-app-bldproj:*"
        ]
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::codepipeline-${var.sys_name}-${var.src_aws_region}-*"
        ]
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ]
        Resource = [
          "arn:aws:codebuild:${var.src_aws_region}:${data.aws_caller_identity.src.account_id}:report-group/${var.sys_name}-app-bldproj-*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "codebuild_app_service_role" {
  provider = aws.source
  
  name = "codebuild-${var.sys_name}-app-service-role"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.app_bldproj_base_policy.arn
  ]

  inline_policy {
    name = "s3-delete-object"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "VisualEditor0"
          Effect   = "Allow"
          Action   = "s3:DeleteObject"
          Resource = "arn:aws:s3:::${module.app_bucket.bucket.bucket}/*"
        }
      ]
    })
  }

  inline_policy {
    name = "s3-sync"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "VisualEditor0"
          Effect = "Allow"
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:ListBucket"
          ]
          Resource = [
            "arn:aws:s3:::${module.app_bucket.bucket.bucket}/*",
            "arn:aws:s3:::${module.app_bucket.bucket.bucket}"
          ]
        }
      ]
    })
  }

  inline_policy {
    name = "ssm-get-parameters"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "VisualEditor0"
          Effect = "Allow"
          Action = [
            "ssm:GetParameters",
            "ssm:GetParameter"
          ],
          Resource = [
            "arn:aws:ssm:*:${data.aws_caller_identity.src.account_id}:parameter/codepipeline/${var.sys_name}-app/*"
          ]
        }
      ]
    })
  }

}

resource "aws_codebuild_project" "app_bldproj" {
  provider = aws.source
  
  name         = "${var.sys_name}-app-bldproj"
  service_role = aws_iam_role.codebuild_app_service_role.arn

  source {
    buildspec = file("${path.module}/files/aws_codebuild_project/app_bldproj/buildspec.yml")
    type      = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "NO_CACHE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }
}

#------------------------------------------#
# CodePipeline resources :: Source account #
#------------------------------------------#

module "codepipeline_sys_bucket" {
  providers = {
    aws = aws.source
  }
  
  source        = "../../modules/s3-bucket"
  bucket        = "codepipeline-${var.sys_name}-${var.src_aws_region}-${data.aws_caller_identity.src.account_id}"
  force_destroy = true
  acl           = "private"
}

resource "aws_iam_policy" "codepipeline_sys_base_policy" {
  provider    = aws.source
  name        = "CodePipelineBasePolicy-${var.sys_name}-${var.src_aws_region}"
  description = "Policy used in trust relationship with CodePipeline"
  path        = "/service-role/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
        Effect   = "Allow"
        Condition = {
          StringEqualsIfExists = {
            "iam:PassedToService" = [
              "cloudformation.amazonaws.com",
              "elasticbeanstalk.amazonaws.com",
              "ec2.amazonaws.com",
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      },
      {
        Action = [
          "codecommit:CancelUploadArchive",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetRepository",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:UploadArchive"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Action = [
          "elasticbeanstalk:*",
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "cloudwatch:*",
          "s3:*",
          "sns:*",
          "cloudformation:*",
          "rds:*",
          "sqs:*",
          "ecs:*"
        ]
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Action = [
          "lambda:InvokeFunction",
          "lambda:ListFunctions"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Action = [
          "opsworks:CreateDeployment",
          "opsworks:DescribeApps",
          "opsworks:DescribeCommands",
          "opsworks:DescribeDeployments",
          "opsworks:DescribeInstances",
          "opsworks:DescribeStacks",
          "opsworks:UpdateApp",
          "opsworks:UpdateStack"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Action = [
          "cloudformation:CreateStack",
          "cloudformation:DeleteStack",
          "cloudformation:DescribeStacks",
          "cloudformation:UpdateStack",
          "cloudformation:CreateChangeSet",
          "cloudformation:DeleteChangeSet",
          "cloudformation:DescribeChangeSet",
          "cloudformation:ExecuteChangeSet",
          "cloudformation:SetStackPolicy",
          "cloudformation:ValidateTemplate"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuildBatches",
          "codebuild:StartBuildBatch"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Effect = "Allow"
        Action = [
          "devicefarm:ListProjects",
          "devicefarm:ListDevicePools",
          "devicefarm:GetRun",
          "devicefarm:GetUpload",
          "devicefarm:CreateUpload",
          "devicefarm:ScheduleRun"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "servicecatalog:ListProvisioningArtifacts",
          "servicecatalog:CreateProvisioningArtifact",
          "servicecatalog:DescribeProvisioningArtifact",
          "servicecatalog:DeleteProvisioningArtifact",
          "servicecatalog:UpdateProduct"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudformation:ValidateTemplate"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:DescribeImages"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "states:DescribeExecution",
          "states:DescribeStateMachine",
          "states:StartExecution"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "appconfig:StartDeployment",
          "appconfig:StopDeployment",
          "appconfig:GetDeployment"
        ]
        Resource = "*"
      }
    ]
  })

}

resource "aws_iam_role" "codepipeline_sys_service_role" {
  provider = aws.source
  name     = "codepipeline-${var.sys_name}-service-role-${var.src_aws_region}"
  path     = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    aws_iam_policy.codepipeline_sys_base_policy.arn
  ]
}

resource "aws_codepipeline" "app_pipeline" {
  provider = aws.source
  name     = "${var.sys_name}-app-pipeline"
  role_arn = aws_iam_role.codepipeline_sys_service_role.arn

  artifact_store {
    location = module.codepipeline_sys_bucket.bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      namespace        = "SourceVariables"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn    = var.app_codestar_connection_arn
        FullRepositoryId = var.app_full_repository_id
        BranchName       = var.app_branch_name
      }
    }
  }
  
  stage {
    name = "Build"

    action {
      run_order        = 1
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      version          = "1"
      namespace        = "BuildVariables"
      output_artifacts = ["BuildArtifact"]

      configuration = {
        ProjectName = aws_codebuild_project.app_bldproj.name
        EnvironmentVariables = jsonencode([
          {
            name  = "DOTENV"
            value = aws_ssm_parameter.codepipeline_app_dotenv.name
            type  = "PARAMETER_STORE"
          },
          {
            name  = "WEBSITE_S3_BUCKET"
            value = aws_ssm_parameter.codepipeline_app_website_s3_bucket.name
            type  = "PARAMETER_STORE"
          },
          {
            name  = "CLOUDFRONT_DIST_ID"
            value = aws_ssm_parameter.codepipeline_app_cloudfront_dist_id.name
            type  = "PARAMETER_STORE"
          }
        ])
      }
    }
    
    action {
      run_order       = 2
      name            = "CloudFrontInvalidation"
      category        = "Invoke"
      owner           = "AWS"
      provider        = "Lambda"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        FunctionName = aws_lambda_function.codepipeline_cloudfront_invalidation_cross_account_fn.function_name
        UserParameters = jsonencode({
          cloudfront_dist_id  = "#{BuildVariables.EXP_CLOUDFRONT_DIST_ID}"
          cross_acct_role_arn = aws_iam_role.cloudfront_assume_role_on_tgt_account_role.arn
        })
      }
    }

  }

}
