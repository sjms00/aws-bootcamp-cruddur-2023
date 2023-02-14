# Week 0 — Billing and Architecture

Install AWS CLI

- Instructions in
https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

For MAC
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

jordimorreres@MBP-de-Jordi ~ % which aws
/usr/local/bin/aws
jordimorreres@MBP-de-Jordi ~ % aws --version
aws-cli/2.9.23 Python/3.9.11 Darwin/19.6.0 exe/x86_64 prompt/off
jordimorreres@MBP-de-Jordi ~ % 





In cloudshell
[cloudshell-user@ip-10-6-5-234 ~]$ aws --cli-auto-prompt
> aws sts get-caller-identity 
{
    "UserId": "AIDATFFIEGJHUHNDJREBQ",
    "Account": "217248445007",
    "Arn": "arn:aws:iam::217248445007:user/JMbootcamp"
}
[cloudshell-user@ip-10-6-5-234 ~]$ 

