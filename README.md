# gl-terraform-gcp

Terraform Google GCP Deep Dive

## Tasks
[Task-1] - initial configuration, gcp project creation
[Task-2] - updated configs and readme, added compute instance 

## To start you need
* buy or rent domain
* create valid credit card and put $1 on it
* create GCP account for organization using you domain, Google will ask you to put file to you domain to verify that you own it
* create at least one (admin) in your GCP organization
* install and configure  `gcloud` for organization admin user
* install `terraform`

## Initial GCP configuration

Got organizations id
```
gcloud organizations list
```
like this
```
DISPLAY_NAME               ID  DIRECTORY_CUSTOMER_ID
example.com  57xxxxxxxxx              C02pxxxx
```

Got billing id
```
gcloud beta billing accounts list
```
```
ACCOUNT_ID            NAME                   OPEN  MASTER_ACCOUNT_ID
vvvvv-ttttttt-xxxxxx  My acc billings        True

```
Configure environment for the Google Cloud Terraform
```
export TF_VAR_org_id=57xxxxxxxx \
export TF_VAR_billing_account=vvvvv-ttttttt-xxxxxx \
export TF_ADMIN=alex-terraform-admin \
export TF_VAR_region=us-central1 \
export TF_VAR_tf_admin_project=${TF_ADMIN} \
export GOOGLE_PROJECT=${TF_ADMIN} \
export GOOGLE_CLOUD_KEYFILE_JSON=creds.json \
export TF_VAR_target_project_id=gjtjfu-9685747 \
export TF_VAR_target_project_name=google-project-589254
```

Create the Terraform Admin Project
```
gcloud projects create ${TF_ADMIN} \
  --organization ${TF_VAR_org_id} \
  --set-as-default

gcloud beta billing projects link ${TF_ADMIN} \
  --billing-account ${TF_VAR_billing_account}
```

Create the Terraform service account
```
gcloud iam service-accounts create terraform \
  --display-name "Terraform admin account"

gcloud iam service-accounts keys create ${TF_CREDS} \
  --iam-account terraform@${TF_ADMIN}.iam.gserviceaccount.com
```

Grant the service account permission to view the Admin Project and manage Cloud Storage

```
gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/viewer

gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/storage.admin
```

Enable GCP APIs

```
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable serviceusage.googleapis.com
```

THE MOST IMPORTANT: Add organization/folder-level permissions

```
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/billing.user
```

Create the remote backend bucket in Cloud Storage

```
gsutil mb -p ${TF_ADMIN} gs://${TF_ADMIN}
```

Enable versioning for said remote bucket:

```
gsutil versioning set on gs://${TF_ADMIN}
```

Initialize the backend, check changes and apply them
```
terraform init
terraform plan
terraform apply
```

At this point you could connect to computer instance using terraform output
```
export instance_id=$(terraform output instance_id)
export project_id=$(terraform output project_id)
gcloud compute ssh ${instance_id} --project ${project_id}
```

Cleaning up
```
terraform destroy

gcloud projects delete ${TF_ADMIN}

gcloud organizations remove-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

gcloud organizations remove-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/billing.user
```