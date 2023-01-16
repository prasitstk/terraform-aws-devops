import boto3
import time
import json
import logging
import os

def lambda_handler(event, context):
  
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    logger.debug(json.dumps(event))
    
    codepipeline = boto3.client('codepipeline')
    job_id = event['CodePipeline.job']['id']
    
    cloudfront_dist_id = None
    cross_acct_role_arn = None
    try:
        user_params = json.loads(event['CodePipeline.job']['data']['actionConfiguration']['configuration']['UserParameters'])
        cloudfront_dist_id = user_params['cloudfront_dist_id']
        cross_acct_role_arn = user_params['cross_acct_role_arn']
    except Exception as error:
        logger.exception(error)
        response = codepipeline.put_job_failure_result(
            jobId=job_id,
            failureDetails={
                'type': 'JobFailed',
                'message': f'{error.__class__.__name__}: {str(error)}'
            }
        )
        logger.debug(response)
        return
    
    sts_connection = boto3.client('sts')
    acct_b = sts_connection.assume_role(
        RoleArn=cross_acct_role_arn,
        RoleSessionName="cross_acct_lambda"
    )

    ACCESS_KEY = acct_b['Credentials']['AccessKeyId']
    SECRET_KEY = acct_b['Credentials']['SecretAccessKey']
    SESSION_TOKEN = acct_b['Credentials']['SessionToken']
    
    client = boto3.client(
        'cloudfront',
        aws_access_key_id=ACCESS_KEY,
        aws_secret_access_key=SECRET_KEY,
        aws_session_token=SESSION_TOKEN,
    )
    
    response = client.create_invalidation(
        DistributionId=cloudfront_dist_id,
        InvalidationBatch={
            'Paths': {
                'Quantity': 1,
                'Items': [
                    '/*',
                ]
            },
            'CallerReference': str(time.time()).replace(".", "")
        }
    )
    invalidation_id = response['Invalidation']['Id']
    
    print("Invalidation created successfully with Id: " + invalidation_id)
    
    try:
        #raise ValueError('This message will appear in the CodePipeline UI.')
        logger.info('Success!')
        response = codepipeline.put_job_success_result(jobId=job_id)
        logger.debug(response)
    except Exception as error:
        logger.exception(error)
        response = codepipeline.put_job_failure_result(
            jobId=job_id,
            failureDetails={
                'type': 'JobFailed',
                'message': f'{error.__class__.__name__}: {str(error)}'
            }
        )
        logger.debug(response)
