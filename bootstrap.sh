#!/usr/bin/env bash

set -e

TERRAFORM_VERSION=0.11.8
TERRAFORM_SHA256SUM=84ccfb8e13b5fce63051294f787885b76a1fedef6bdbecf51c5e586c9e20c9b7

TERRAFORM_APACHE2_REPO_URL="https://github.com/kevinhead/terraform-apache2"

# Install dependencies.
apt-get install -y unzip \
                   curl \
                   git \
                   apache2

# Download Terraform
curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    echo "${TERRAFORM_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    sha256sum --check --strict terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Clone Terraform Apache2 from Github and apply
git clone ${TERRAFORM_APACHE2_REPO_URL} /tmp/tf-apache2 && \
    cd /tmp/tf-apache2 && \
    terraform init && \
    terraform plan && \
    terraform apply -auto-approve