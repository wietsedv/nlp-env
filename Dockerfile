#syntax=docker/dockerfile:1.2
FROM --platform=linux/amd64 wietsedv/micromamba:latest

COPY conda-linux-64.lock .
RUN --mount=type=cache,target=/opt/conda/pkgs micromamba install -y -n base -f conda-linux-64.lock && \
    mamba clean -tiy

ENTRYPOINT [ "/bin/bash", "-c" ]
CMD [ ]
