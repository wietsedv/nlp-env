FROM --platform=linux/amd64 condaforge/mambaforge:latest

ENV PATH=/env/bin:${PATH}
RUN sed -i "s#conda activate base#conda activate /env#" ~/.bashrc

# Base
COPY envs/base-linux-64.lock .
RUN --mount=type=cache,target=/opt/conda/pkgs mamba create -p /env --file base-linux-64.lock

# Regular
COPY envs/regular-linux-64-delta.lock .
RUN --mount=type=cache,target=/opt/conda/pkgs mamba install -p /env --file regular-linux-64-delta.lock
