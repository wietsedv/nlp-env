FROM --platform=linux/amd64 wietsedv/micromamba:latest

# Base
COPY envs/base-linux-64.lock .
RUN micromamba install -y -n base -f base-linux-64.lock --always-softlink && \
    micromamba clean -y -a

# Regular
COPY envs/regular-linux-64.lock .
RUN micromamba install -y -n base -f regular-linux-64.lock --always-softlink && \
    micromamba clean -y -a
