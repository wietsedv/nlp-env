#!/usr/bin/env bash
set -e

conda-lock -p osx-arm64 -p linux-64

if ! git diff --exit-code conda-linux-64.lock; then
    git add .
    git commit -m "update lock [$(date --iso-8601)]"
    git push origin main
fi
