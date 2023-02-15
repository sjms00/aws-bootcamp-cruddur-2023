# Week 0 — Billing and Architecture

## Install AWS CLI

- Install AWS CLI when Gidpot environment launch
- To insall AWS CLI, the instructions are in https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Update the .gitpod.yml to include the task to install AWS CLI


```sh
tasks:
  - name: aws-cli
    env:
      AWS_CLI_AUTO_PROMPT: on-partial
    init: 
      cd /workspace
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
      cd $THEIA_WORKSPACE_ROOT
```

### Create a new User and Generate AWS Credentials

- Go to (IAM Users Console] and create a new user
- `Enable console access` for the user
- Create a new `Admin` Group and apply `AdministratorAccess`
- Create the user and go find and click into the user
- Click on `Security Credentials` and `Create Access Key`
- Choose AWS CLI Access
- Download the CSV with the credentials


We'll tell Gitpod to remember these credentials if we relaunch our workspaces
```
gp env AWS_ACCESS_KEY_ID=""
gp env AWS_SECRET_ACCESS_KEY=""
gp env AWS_DEFAULT_REGION="us-east-1"
```

### Check that the AWS CLI is working and you are the expected user

```sh
aws sts get-caller-identity
```

You should see something like this:
```json
{
    "UserId": "AIDATFFIEGJHUHNDJREBQ",
    "Account": "217248445007",
    "Arn": "arn:aws:iam::217248445007:user/JMbootcamp"
}
```

## Enable Billing 

We need to turn on Billing Alerts to recieve alerts...

