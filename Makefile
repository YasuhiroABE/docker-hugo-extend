
DOCKER_CMD = podman
HUGO_GIT_PROJECT_NAME = hugo-example
HUGO_CONTENTS_DEST_PATH = /public

HUGO_VERSION = v0.154.5

NAME = hugo-extend
DOCKER_IMAGE = hugo-extend
DOCKER_IMAGE_VERSION = my-extended-$(HUGO_VERSION)

IMAGE_NAME = $(DOCKER_IMAGE):$(DOCKER_IMAGE_VERSION)

REGISTRY_SERVER = docker.io
REGISTRY_LIBRARY = yasuhiroabe

PROD_IMAGE_NAME = $(REGISTRY_SERVER)/$(REGISTRY_LIBRARY)/$(IMAGE_NAME)


.PHONY: all
all:
	@echo "Usage: make (build|build-prod|tag|push|run|stop|clean)"

.PHONY: git-push
git-push:
	git push
	git push --tags

.PHONY: build
build:
	$(DOCKER_CMD) build . --tag $(DOCKER_IMAGE) --build-arg hugo_version=$(HUGO_VERSION)

.PHONY: build-prod
build-prod:
	$(DOCKER_CMD) build . --pull --tag $(IMAGE_NAME) --no-cache --build-arg hugo_version=$(HUGO_VERSION)

.PHONY: tag
tag:
	$(DOCKER_CMD) tag $(IMAGE_NAME) $(PROD_IMAGE_NAME)

.PHONY: push
push:
	$(DOCKER_CMD) push $(PROD_IMAGE_NAME)

.PHONY: run
run:
	sudo rm -fr public
	mkdir public
	chmod 0777 public
	$(DOCKER_CMD) run -it --rm \
		-e HUGO_GIT_PROJECT_NAME=$(HUGO_GIT_PROJECT_NAME) \
		-e HUGO_CONTENTS_DEST_PATH=$(HUGO_CONTENTS_DEST_PATH) \
		-v `pwd`/public:/public \
		--name $(NAME) \
		$(DOCKER_IMAGE)

.PHONY: stop
stop:
	$(DOCKER_CMD) stop $(NAME)

.PHONY: clean
clean:
	find . -name '*~' -type f -exec rm {} \; -print
