# Configure Access

~~After installation create local authentication credentials for your user account with `gcloud auth application-default login`.~~

`gcloud auth application-default login` is not an approved method. Request a service account via JIRA and use the credential json key file for access instead.

# Configure Remote State Storage Account

Create a Cloud Storage bucket:

```
PROJECT_NAME=fe-dev-sandbox
BUCKET_NAME=jlieow-tfstate-54321abcde

gcloud config set project $PROJECT_NAME
gcloud storage buckets create gs://$BUCKET_NAME --location=EU
```

In order to use a GCS bucket for remote state storage, you will need to configure gcloud cli to use the json key file to access the bucket: 
`export GOOGLE_APPLICATION_CREDENTIALS="LOCATION/OF/JSON/KEY/FILE"`