#!/bin/bash
set -e

apt-get update -y
apt-get install -y awscli git

HOME=/home/ubuntu

aws secretsmanager get-secret-value \
  --region us-east-1 \
  --secret-id "myproject/privkey" \
  --query "SecretString" \
  --output text > $HOME/.ssh/repo_key.pem

chmod 600 $HOME/.ssh/repo_key.pem

cat > $HOME/.ssh/config <<- EOF
Host github.com
  Hostname github.com
  IdentityFile=~/.ssh/repo_key.pem
EOF

ssh-keyscan github.com >> $HOME/.ssh/known_hosts
chown ubuntu:ubuntu $HOME/.ssh/*

su - ubuntu -c "cd ; git clone git@github.com:pwr-cloudprogramming/clprog2026-a04-thu1304.git"