# Dockerfile for plotting processes (SAMtools + matplotlib)
FROM mambaorg/micromamba:1.5.8

LABEL maintainer="student@itmo.ru"
LABEL description="Docker image for coverage plotting (SAMtools + Python/matplotlib)"

USER root

ENV MAMBA_ROOT_PREFIX=/opt/conda

RUN micromamba install -y -p /opt/conda -c bioconda -c conda-forge \
    samtools=1.17 \
    matplotlib=3.7.2 \
    python=3.11 && \
    micromamba clean -a -y

ENV PATH="/opt/conda/bin:${PATH}"
