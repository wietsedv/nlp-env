#!/usr/bin/env bash

# Base
conda-lock -p linux-64 -p osx-arm64 \
    -f envs/base.yml \
    --filename-template "envs/base-{platform}.lock"

# Regular
conda-lock -p linux-64 -p osx-arm64 \
    -f envs/base.yml -f envs/regular.yml \
    --filename-template "envs/regular-{platform}.lock"

# Extra packages
head -n3 envs/regular-linux-64.lock > envs/regular-linux-64-delta.lock
diff <(sort envs/base-linux-64.lock) <(sort envs/regular-linux-64.lock) | grep -o '^> http.*' | grep -o 'http.*' >> envs/regular-linux-64-delta.lock

# Disappeared packages
d=$(diff <(sort envs/base-linux-64.lock) <(sort envs/regular-linux-64.lock) | grep -o '^< http.*' | grep -o 'http.*')
if [ ! -z "$d" ]; then
    echo "ERROR: These packages have disappeared in the 'regular' environment:"
    printf "$d"
    exit 1
fi
