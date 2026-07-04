#!/bin/bash
set -euxo pipefail

# Update packages
dnf update -y

# Install Python 3 and pip
dnf install -y python3 python3-pip

# Verify installation
python3 --version
pip3 --version