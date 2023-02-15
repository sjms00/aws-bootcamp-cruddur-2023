# Week 0 — Billing and Architecture

## Install AWS CLI

- Install AWS CLI when Gidpot environment launch
- To insall AWS CLI, the instructions are in https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Update the .gitpod.yml to include the task to install AWS CLI


\tasks:
  - name: aws-cli
    env:
      AWS_CLI_AUTO_PROMPT: on-partial
    init: |
      cd /workspace
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
      cd $THEIA_WORKSPACE_ROOT
\
