# Configure Access

After installation create local authentication credentials for your user account with `gcloud auth application-default login`.

# Configure Remote State Storage Account

Create a Cloud Storage bucket:

```
PROJECT_NAME=fe-dev-sandbox
BUCKET_NAME=jlieow-tfstate-54321abcde

gcloud config set project $PROJECT_NAME
gcloud storage buckets create gs://$BUCKET_NAME --location=EU
```