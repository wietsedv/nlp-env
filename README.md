# Basic NLP environment
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/wietsedv/nlp)
![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/wietsedv/nlp)
![Docker Pulls](https://img.shields.io/docker/pulls/wietsedv/nlp)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/wietsedv/nlp/latest)

This is the basic [mamba](https://github.com/mamba-org/mamba) (== conda) environment with packages that I would need for any NLP related project. The lock files and [Docker image](https://hub.docker.com/r/wietsedv/nlp) are updated daily.

## Usage

```dockerfile
FROM wietsedv/nlp:latest

COPY environment.yaml .

RUN micromamba install -y -f environment.yaml && \
    micromamba clean --all --yes
```

The `latest` tag will stay up to date. If version pinning is necessary, add the tag to the Github repository. The tag will then become available in Docker.
