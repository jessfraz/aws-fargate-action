FROM r.j3ss.co/terraform:latest

LABEL "com.github.actions.name"="AWS Fargate"
LABEL "com.github.actions.description"="Deploy to AWS Fargate on push to the master branch"
LABEL "com.github.actions.icon"="cloud"
LABEL "com.github.actions.color"="red"

RUN apk add --no-cache \
	git \
	make

COPY terraform /usr/src/terraform
COPY Makefile /usr/src
COPY deploy.sh /usr/local/bin/deploy

WORKDIR /usr/src

ENTRYPOINT ["deploy"]
