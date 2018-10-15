# Vagrant box

## Overview

Vagranfile creates a single instance of Ubuntu 16.04 virtual machine in order to host any number of virtual hosts.

## Provisioning (bootstrap.sh)

    - installs required dependencies (git, apache2..)
    - applies Terraform from github.com/kevinhead/terraform-apache2

## Requirements

    - Virtualbox
    - Hashicorp Vagrant
    - Git

## Usage

    - git clone <repository_url>
    - cd <repo_directory>
    - vagrant up

## Additional notes

Once VM has been provisioned using default repo additional manual validation can be done.

    - vagrant ssh
    - curl https://foo.com
    - curl https://bar.com

Example output of 'bar.com' would be the following.

```html
<html>

<head>
    <title>Welcome to bar.com!</title>
</head>

<body>
    <h1>Success! The bar.com virtual host is working!</h1>
</body>

</html>
```