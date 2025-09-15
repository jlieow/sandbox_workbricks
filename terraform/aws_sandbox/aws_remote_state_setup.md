# Configure Access

Use `aws configure sso`.

In the "AWS access portal" which lists all all the accounts that can be accessed, the SSO sign-in info along with other very useful secrets can be found via the "Access keys" link. 

![AWS Access Portal](image.png)

To set a default profile create a new profile called default:
```
[profile default]
sso_session = xxx
sso_account_id = xxx
sso_role_name = xxx
```

# Configure Remote State Storage Account

Create a S3 bucket:

```
BUCKET_NAME=jlieow-tfstate-54321abcde

aws s3api create-bucket --bucket $BUCKET_NAME --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2
```