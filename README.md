# AWS Fargate Action

[![Travis CI](https://img.shields.io/travis/jessfraz/aws-fargate-action.svg?style=for-the-badge)](https://travis-ci.org/jessfraz/aws-fargate-action)

A GitHub action to deploy to AWS Fargate on push to the master branch. 


```
workflow "on push to master, deploy to aws fargate" {
  on = "push"
  resolves = ["fargate deploy"]
}

action "fargate deploy" {
  uses = "jessfraz/aws-fargate-action@master"
  env = {
    AWS_REGION = "us-west-2"
    IMAGE = "r.j3ss.co/party-clippy"
    PORT = "8080"
    COUNT = "2"
    CPU = "256"
    MEMORY = "512"
    BUCKET = "aws-fargate-action"
  }
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
}
```

> **NOTE:** The bucket above needs to be in the same region as `AWS_REGION` AND
> it needs to be created before running the action. That is the only
> prerequisite.

### Tests

The tests use [shellcheck](https://github.com/koalaman/shellcheck). You don't
need to install anything. They run in a container.

```console
$ make test
```

### Using the `Makefile`

```console
$ make help
aws-apply                      Run terraform apply for Amazon.
aws-destroy                    Run terraform destroy for Amazon.
aws-plan                       Run terraform plan for Amazon.
shellcheck                     Runs the shellcheck tests on the scripts.
test                           Runs the tests on the repository.
update-terraform               Update terraform binary locally from the docker container.
update                         Update terraform binary locally.
```
