#!/bin/bash
set -e
set -o pipefail

if [[ "$GITHUB_REF" != "refs/heads/master" ]]; then
	echo "$GITHUB_REF was not master, exiting..."
	exit 0
fi

make aws-apply TERRAFORM_FLAGS=-auto-approve
