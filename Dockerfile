FROM mambaorg/micromamba:latest

COPY conda-linux-64.lock .

RUN micromamba install -y -n base -f conda-linux-64.lock && \
    micromamba clean --all --yes