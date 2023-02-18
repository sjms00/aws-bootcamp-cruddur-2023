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
    init: |
      cd /workspace
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
      cd $THEIA_WORKSPACE_ROOT
```

### Create a new User and Generate AWS Credentials
I will create my new user JMbootcamp

- Go to (IAM Users Console] and create a new user
- `Enable console access` for the user
- Create a new `Admin` Group and apply `AdministratorAccess`
- Create the user and go find and click into the user
- Click on `Security Credentials` and `Create Access Key`
- Choose AWS CLI Access
- Download the CSV with the credentials
- Activate de MFA for the new user

![Create Admin user](_docs/assets/week0/Admin_user.png) 

I'll update Gitpod variables to remember my credentials
```
gp env AWS_ACCESS_KEY_ID="**** ....."
gp env AWS_SECRET_ACCESS_KEY="**** ....."
gp env AWS_DEFAULT_REGION="us-east-1"
```

### Check that the AWS CLI is working and you are the expected user

```sh
aws sts get-caller-identity
```
Show my identity:
![aws sts get-caller-identity](_docs/assets/week0/get_caller_identity.png) 

### Configure local development environment with Visual Code atached with my gidhab repository
I'll use my local development tools, with Visual Studio Code

![Visual Code Config](_docs/assets/week0/Visual_code_config.png)


## Enable Billing Alerts

We need to turn on Billing Alerts to recieve alerts...

### Create SNS Topic

- I need an SNS topic before I create an alarm.
- The SNS topic is what will delivery us an alert when I get overbilled
- [aws sns create-topic](https://docs.aws.amazon.com/cli/latest/reference/sns/create-topic.html)

I'll create a SNS Topic
```sh
aws sns create-topic --name billing-alarm
```
"TopicArn": "arn:aws:sns:us-east-1:217248445007:billing-alarm"

which will return a TopicARN

We'll create a subscription supply the TopicARN and our Email
```sh
aws sns subscribe \
    --topic-arn="arn:aws:sns:us-east-1:217248445007:billing-alarm" \
    --protocol=email \
    --notification-endpoint=jmorreres@andorra.ad
```

Check email and confirm the subscription

#### Create Alarm

- [aws cloudwatch put-metric-alarm](https://docs.aws.amazon.com/cli/latest/reference/cloudwatch/put-metric-alarm.html)
- [Create an Alarm via AWS CLI](https://aws.amazon.com/premiumsupport/knowledge-center/cloudwatch-estimatedcharges-alarm/)
- We need to update the configuration json script with the TopicARN we generated earlier
- We are just a json file because --metrics is is required for expressions and so its easier to us a JSON file.

```sh
aws cloudwatch put-metric-alarm --cli-input-json file://aws/json/alarm_config.json
```

## Create an AWS Budget
I crated an Alert when the budget when it reaches 100$, I use the account for my web also
[aws budgets create-budget](https://docs.aws.amazon.com/cli/latest/reference/budgets/create-budget.html)

Get your AWS Account ID
```sh
aws sts get-caller-identity --query Account --output text
```

- Supply your AWS Account ID
- Update the json files
- This is another case with AWS CLI its just much easier to json files due to lots of nested json

```sh
aws budgets create-budget \
    --account-id 217248445007 \
    --budget file://aws/json/budget.json \
    --notifications-with-subscribers file://aws/json/budget-notifications-with-subscribers.json
```
![Create budget Alert](_docs/assets/week0/Budget_alert.png)

### Cruddur Conceptual Diagram

[Lucid Chart Conceptual Diagram Share Link](https://lucid.app/lucidchart/d450e2fa-da55-4f2f-8cba-a54fff53fada/edit?viewport_loc=-1460%2C133%2C1579%2C1077%2C0_0&invitationId=inv_69c7750a-3dae-4ba8-82bc-9a91b613bb7d![image](https://user-images.githubusercontent.com/37512346/219849175-ff28a336-dee2-4054-9084-9d29f32a8928.png)
)

![Image of The Conceptual Diagram](_docs/assets/week0/cruddur_Conceptual_Diagram.png) 

### Cruddur Architectual diagram

[Lucid Chart Architectural Diagram Share Link](https://lucid.app/lucidchart/043298e9-7b3e-4ba9-94a4-cc3466f7f525/edit?view_items=9C4xYp1cbfzw&invitationId=inv_6a5b5d81-b8bf-492a-b70a-7542f342cb5f![image](https://user-images.githubusercontent.com/37512346/219849185-67a3eee6-ccad-4ec0-8b5b-f0b21399f3fe.png)
)

![Image of The Architectual Diagram](_docs/assets/week0/cruddur_Architectual_Diagram.png) 

