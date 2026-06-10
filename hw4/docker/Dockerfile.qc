# Dockerfile for QC processes (FastQC, Trimmomatic)
FROM mambaorg/micromamba:1.5.8

LABEL maintainer="student@itmo.ru"
LABEL description="Docker image for QC processes (FastQC, Trimmomatic)"

USER root

ENV MAMBA_ROOT_PREFIX=/opt/conda

RUN micromamba install -y -p /opt/conda -c bioconda -c conda-forge \
    fastqc=0.12.1 \
    trimmomatic=0.39 && \
    micromamba clean -a -y

ENV PATH="/opt/conda/bin:${PATH}"
