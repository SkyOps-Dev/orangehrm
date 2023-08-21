# Infrastructure Deployment Workflow
This GitHub Actions workflow automates the deployment of infrastructure using AWS CloudFormation, S3, and EC2. It performs various tasks, such as creating key pairs, uploading files to S3, deploying CloudFormation stacks, and storing important information in AWS Parameter Store. The workflow consists of one job:
* **deploy.**

# Workflow Details
## Workflow Trigger
The workflow is triggered when a push event occurs on the **5.1-ec2-docker-infra** branch.

## 1. Job: deploy
1. **Checkout Code**: This step checks out the repository code to be used in subsequent steps.

2. **Set up AWS CLI**: Configures AWS CLI credentials by assuming a specified AWS role.

3. **Check if key pair exists**: Checks if the specified key pair exists; creates it if not.

4. **Check if key exists in Parameter Store**: Checks if the private key exists in AWS Parameter Store; stores it if not.

5. **Create S3 Bucket**: Creates an S3 bucket to hold CloudFormation templates and related files.

6. **Upload Files to S3 Bucket**: Uploads necessary files to the S3 bucket.

7. **Check List of files in S3 Bucket**: Lists the files available in the S3 bucket.

8. **Fetch Main Stack Template**: Retrieves the Main Stack template from the S3 bucket.

9. **Check if Main Stack Exists**: Checks if the Main Stack already exists using CloudFormation.

10. **Deploy Main Stack**: Deploys the Main Stack using CloudFormation if it doesn't already exist.

11. **List CloudFormation Stacks**: Lists CloudFormation stacks related to EC2 instances and retrieves instance information.

## Prerequisites

- AWS IAM Role: Ensure you have an AWS IAM role set up with the necessary permissions for creating key pairs, interacting with EC2, S3, and CloudFormation, and using AWS Systems Manager Parameter Store.

## Trust Relationship Policy for AWS IAM role
The role to assume should have the following trust relationship policy:
```console
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::<aws-account-ID>:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:<GithubUserName>/<GithubRepoName>:*",
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}
```
Make sure to replace "repo:(GithubUserName)/(GithubRepoName):*" with the appropriate GitHub repository name and organization/user name, depending on your specific repository structure. Also, verify that the specified (aws-account-ID) is correct for your setup.


## Permissions for AWS IAM role
To grant the necessary permissions to the role, ensure the following policies are attached:

* **AmazonEC2FullAccess** Provides full access to Amazon EC2 via the AWS Management Console.
* **IAMFullAccess** Provides full access to IAM via the AWS Management Console.
* **AmazonS3FullAccess** Provides full access to all buckets via the AWS Management Console.
* **AmazonSSMFullAccess** Provides full access to Amazon SSM.
* **AWSCloudFormationFullAccess** Provides full access to AWS CloudFormation.
Attach these policies to the AWS IAM role.

Please note that the permissions mentioned above provide full access to EC2, IAM, S3, SSM, and CloudFormation. Adjust the permissions as needed based on your requirements and security considerations.

## Configuration

- **Branches**: The workflow is triggered when a push is made to the `5.1-ec2-docker-infra` branch. You can adjust this in the `on` section of the workflow.

- **Environment Variables**: Modify the environment variables in the `env` section to match your specific configuration.

- **Secrets**: Ensure that the necessary secrets, such as `AWS_ROLE_TO_ASSUME`, are set up in your GitHub repository.

## Usage

1. Ensure that your AWS IAM role and permissions are correctly set up.

2. Update the environment variables and other configuration parameters as needed.

3. Create or modify the `.github/workflows/infra.yml` file in your repository with the contents of the provided workflow.

4. Push your changes to the `5.1-ec2-docker-infra` branch to trigger the workflow.
