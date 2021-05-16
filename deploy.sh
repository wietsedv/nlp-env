#!/usr/bin/env bash

TAG=$1

TGT_CONTEXT="per"

HASH=$(cat docker-image.lock | sed "s/^sha256://")
SRC_DIR="/mnt/E/p300332/singularity"
SRC_PATH="${SRC_DIR}/${HASH}-*.sif"
TGT_DIR="/scratch/p300332/singularity"
TGT_PATH="${TGT_DIR}/images/${HASH}.sif"

if [ -z $DOCKER_CONTEXT ]; then
    echo "Deployment must be done remotely, but DOCKER_CONTEXT is not set."
    exit 1
fi

echo "img:$HASH"
echo "$DOCKER_CONTEXT:${SRC_PATH}"
echo "$TGT_CONTEXT:${TGT_PATH}"

# Skip if it already exists
if ssh $TGT_CONTEXT "test -e ${TGT_PATH}"; then
    echo "Image is already deployed. Relinking"
    ssh $TGT_CONTEXT "ln -sf ${TGT_PATH} ~/library/${TAG}.sif"
    exit 0
fi

# Export singularity image if it does not exist
if ssh $DOCKER_CONTEXT "test -e ${SRC_PATH}"; then
    echo "Singularity image is already exported"
else
    ssh $DOCKER_CONTEXT mkdir -p "${SRC_DIR}"
    docker run --rm \
        -v /run/user/10300332/docker.sock:/var/run/docker.sock \
        -v ${SRC_DIR}:/output \
        quay.io/singularity/docker2singularity \
        ${HASH}
fi

# Upload the singularity image
echo "Uploading to $TGT_CONTEXT"
sshpass -f ~/.secret scp $DOCKER_CONTEXT:${SRC_PATH} $TGT_CONTEXT:${TGT_PATH}.tmp
ssh $TGT_CONTEXT "mv ${TGT_PATH}.tmp ${TGT_PATH} && ln -sf ${TGT_PATH} ~/library/${TAG}.sif"

# Cleanup
ssh $DOCKER_CONTEXT rm ${SRC_PATH}

echo "Done!"