all:
	make lock
	make build
	make deploy

TAG=nlp

# Lock files
conda-linux-64.lock:
	conda-lock lock -p linux-64
conda-osx-arm64.lock:
	conda-lock lock -p osx-arm64

.PHONY: lock
lock: clean-lock conda-linux-64.lock conda-osx-arm64.lock

.PHONY: install
install: conda-osx-arm64.lock
	mamba install -n $(TAG) --file conda-osx-arm64.lock

# Docker build
docker-image.lock: conda-linux-64.lock
	docker buildx build . --tag $(TAG) --platform=linux/amd64
	docker inspect --format='{{.Id}}' $(TAG) > docker-image.lock

.PHONY: build
build:
	rm -f docker-image.lock
	make docker-image.lock

.PHONY: run
run:
	docker run --rm -it $(TAG)

# TODO Dynamically get SOCK
.PHONY: deploy
deploy: docker-image.lock
	./deploy.sh $(TAG)

# Clean
.PHONY: clean-lock
clean-lock:
	rm -f *.lock

.PHONY: clean
clean: clean-lock
	docker image prune -f
