FROM --platform=linux/amd64 condaforge/mambaforge:latest

ENV PATH=/env/bin:${PATH}
RUN sed -i "s#conda activate base#conda activate /env#" ~/.bashrc

# Base
COPY envs/base-linux-64.lock .
RUN mamba create -p /env --file base-linux-64.lock && \
    mamba clean -afy

# Regular
COPY envs/regular-linux-64-delta.lock .
RUN mamba install -p /env --file regular-linux-64-delta.lock && \
    mamba clean -afy
