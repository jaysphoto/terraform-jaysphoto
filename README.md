
# Terraform initialization
Configure the [AWS CLI](https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-envvars.html) with an account that has sufficient permissions, or sign in to the AWS Console.

Set the desired AWS Profile and Region:
```
export AWS_REGION=us-west-1
export AWS_PROFILE=default
```

## Bootstrap Terraform S3 Backend
**Remember to replace the S3 bucket name and region to your own values.**

Create an AWS S3 Bucket to hold the terraform state, in the correct region and with versioning enabled:
```
aws s3 mb s3://terraform-jaysphoto-state --region us-west-1
```

Create the backend configuration file `state.config`:
```
bucket = "terraform-jaysphoto-state" 
key    = "aws/terraform.tfstate"
region = "us-west-1"

```

Initialize the new Terraform Backend, in the same region with the S3 bucket that was created:
```
% terraform init -backend-config="./state.config"
Initializing the backend...
Backend configuration changed!

Terraform has detected that the configuration specified for the backend
has changed. Terraform will now check for existing state in the backends.

Successfully configured the backend "s3"!
```

And then apply the S3 bucket policy with terraform:
```
% terraform apply
```
