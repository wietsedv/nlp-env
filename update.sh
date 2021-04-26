#!/usr/bin/env bash
set -e

conda-lock -p osx-arm64 -p linux-64

if git diff --exit-code conda-linux-64.lock; then
    echo "no changes detected. not pusing new lock file"
    exit 0
fi

git add .
git commit -m "update lock [$(date --iso-8601)]"
git push origin main
echo "lock file has been updated"
