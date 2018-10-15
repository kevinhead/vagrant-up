#!/usr/bin/env bash

set -e

TERRAFORM_VERSION=0.11.8
TERRAFORM_SHA256SUM=84ccfb8e13b5fce63051294f787885b76a1fedef6bdbecf51c5e586c9e20c9b7

# Directory from which repo will be cloned and terraform will be ran.
TERRAFORM_WORK_DIR="/tmp/terraform-a2"
# Github repository which contains the Apache2 plan
TERRAFORM_APACHE2_REPO_URL="https://github.com/kevinhead/terraform-apache2"
TERRAFORM_APACHE2_REPO_TAG="v0.1.1"

HTTPS_FOO_URL="https://foo.com"
HTTPS_BAR_URL="https://bar.com"

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

install_deps() {
    # base dependencies.
    apt-get install -y unzip \
                       curl \
                       git \
                       apache2

    if command_exists terraform; then
        echo "terraform already downloaded. skipped"
    else
        # Download Terraform
        curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
            echo "${TERRAFORM_SHA256SUM}  terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
            sha256sum --check --strict terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
            unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
            rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip
    fi
}

# Apache2 helper functions
a2_restart() {
    service apache2 restart
}

a2_https_check() {
    local status=$(curl -s -o /dev/null -w '%{http_code}' $@)

    if [ ${status} -eq 200 ]; then
        echo "${@} - OK!"
    else
        echo "${@} - ${status} - FAILED!"
    fi
}

a2_disable_default_site() {
    a2dissite 000-default.conf
    a2_restart
}

a2_disable_http() {
    sed -i 's/Listen 80//g' /etc/apache2/ports.conf
    a2_restart
}

a2_add_ssl_module() {
    a2enmod ssl
    a2_restart
}

clone_repo() {
    # check if repo already cloned.
    if [ -d "${TERRAFORM_WORK_DIR}" ]; then 
        echo "repo already cloned. skipped."
    else
        git clone --branch ${TERRAFORM_APACHE2_REPO_TAG} ${TERRAFORM_APACHE2_REPO_URL} ${TERRAFORM_WORK_DIR}
    fi
}

do_work() {
    install_deps

    a2_disable_default_site
    a2_disable_http
    a2_add_ssl_module

    clone_repo

    # initialize and apply apache2 plan
    cd ${TERRAFORM_WORK_DIR}
    terraform init
    terraform apply -auto-approve

    # add slight pause to allow service reloads to complete
    sleep 5

    # confirm default repo sites
    a2_https_check ${HTTPS_FOO_URL}

    a2_https_check ${HTTPS_BAR_URL}
}

do_work