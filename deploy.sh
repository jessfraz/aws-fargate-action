#!/bin/bash
set -e
set -o pipefail

make aws-apply TERRAFORM_FLAGS=-auto-approve
