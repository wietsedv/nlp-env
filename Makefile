all: clean
	$(MAKE) lock
	$(MAKE) build
	$(MAKE) deploy

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
	$(MAKE) docker-image.lock

.PHONY: run
run:
	docker run --rm -it $(TAG)

HASH=$(shell cat docker-image.lock | sed "s/^sha256://")
SRC_DIR=/mnt/E/p300332/singularity
SRC_PATH=$(SRC_DIR)/$(HASH)-*.sif
TGT_DIR=/scratch/p300332/singularity
TGT_PATH=$(TGT_DIR)/images/$(HASH).sif

# TODO Dynamically get SOCK
.PHONY: deploy
deploy: docker-image.lock
	ssh per [[ -f $(TGT_PATH) ]] && \
echo "Already deployed (relinking)" && \
ssh per "ln -sf $(TGT_PATH) ~/library/$(TAG).sif" && \
exit 1 || echo "Start deployment"

	ssh $$DOCKER_CONTEXT mkdir -p $(SRC_DIR)
	ssh $$DOCKER_CONTEXT [ -f $(SRC_PATH) ] || \
		docker run --rm \
			-v /run/user/10300332/docker.sock:/var/run/docker.sock \
			-v $(SRC_DIR):/output \
			quay.io/singularity/docker2singularity \
			-m "/scratch /data" \
			$(HASH)
	sshpass -f ~/.secret scp $$DOCKER_CONTEXT:$(SRC_PATH) per:$(TGT_PATH).tmp
	ssh per "mv $(TGT_PATH).tmp $(TGT_PATH) && ln -sf $(TGT_PATH) ~/library/$(TAG).sif"
	ssh $$DOCKER_CONTEXT rm -rf $(SRC_PATH)

# Clean
.PHONY: clean-lock
clean-lock:
	rm -f *.lock

.PHONY: clean
clean: clean-lock
	docker image prune -f
