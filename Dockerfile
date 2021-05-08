FROM mambaorg/micromamba:latest

COPY conda-linux-64.lock .

RUN micromamba install -y -n base -f conda-linux-64.lock --allow-softlinks && \
    micromamba clean -y -a
