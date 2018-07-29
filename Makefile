#
# Makefile for Docker images by Jeffrey Breen <https://www.github.com/JeffreyBreen/>
# 
# based on <https://www.itnotes.de/docker/development/tools/2014/08/31/speed-up-your-docker-workflow-with-a-makefile/>
#

#
## start by including any environment variables you need
include .env

# build-time:
REPO = docker.io
NS = jeffreybreen
IMAGE = ubuntu18-blobfuse

VERSION ?= latest
INSTANCE ?= default

# run-time:
PORTS ?= 
VOLUMES ?=

#
## Pass Azure environment variables for blobfuse
#
# 1. Specify AZURE_STORAGE_ACCESS_KEY or AZURE_STORAGE_SAS_TOKEN -- not both
#
# 2. If the calling shell already has the proper environment variables set, 
#    uncomment the following lines to include their values automatically
ENV = \
  -e AZURE_STORAGE_ACCOUNT \
  -e AZURE_STORAGE_SAS_TOKEN \
  -e AZURE_STORAGE_ACCOUNT_CONTAINER \
  -e AZURE_MOUNT_POINT

# 3. If this Makefile is reading in the environment variables (e.g., via the 
#    above `include .env`), then you need to specify their values when you
#    call `docker run`. CAUTION: This exposes their value on the command line.
#
# ENV = \
#   -e AZURE_STORAGE_ACCOUNT="${AZURE_STORAGE_ACCOUNT}" \
#   -e AZURE_STORAGE_SAS_TOKEN="${AZURE_STORAGE_SAS_TOKEN}" \
#   -e AZURE_STORAGE_ACCOUNT_CONTAINER="${AZURE_STORAGE_ACCOUNT_CONTAINER}" \
#   -e AZURE_MOUNT_POINT="${AZURE_MOUNT_POINT}"
#
# 4. The `--env-file` flag to `docker run` is a much better option for file-based storage of credentials
#
# ENV = --env_file /path/to/azure_secrets.env
#

#
## FUSE requires MKNOD and SYS_ADMIN privileges:
RUN_OPTS = \
    --cap-add=MKNOD --cap-add=SYS_ADMIN \
    --device=/dev/fuse
    

.PHONY: build push shell run start stop rm release

build:
	docker build -t $(NS)/$(IMAGE):$(VERSION) .

push:
	docker push $(REPO)/$(NS)/$(IMAGE):$(VERSION)

run:
	docker run --rm --name $(IMAGE)-$(INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(RUN_OPTS) $(NS)/$(IMAGE):$(VERSION)

shell:
	docker run --rm --name $(IMAGE)-$(INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(RUN_OPTS) $(NS)/$(IMAGE):$(VERSION) /bin/bash

start:
	docker run -d --name $(IMAGE)-$(INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(RUN_OPTS) $(NS)/$(IMAGE):$(VERSION)

stop:
	docker stop $(IMAGE)-$(INSTANCE)

rm:
	docker rm $(IMAGE)-$(INSTANCE)

release: build
	make push -e VERSION=$(VERSION)

default: build
