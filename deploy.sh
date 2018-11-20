#!/bin/bash
set -e
set -o pipefail

if [[ "$GITHUB_REF" != "refs/heads/master" ]]; then
	echo "$GITHUB_REF was not master, exiting..."
	exit 0
fi

echo "On branch ${GITHUB_REF}, deploying..."

(
cd /usr/src
make aws-apply TERRAFORM_FLAGS=-auto-approve
)
