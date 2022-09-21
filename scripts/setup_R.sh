#!/bin/bash
set -e

# update littler to 0.3.16
R -e "install.packages('littler', repos='https://mirrors.tuna.tsinghua.edu.cn/CRAN/')"

# enable installBioc
ln -s ${R_HOME}/site-library/littler/examples/installBioc.r /usr/local/bin/installBioc.r

# change bioconductor mirror
echo "options(BioC_mirror='https://mirrors.tuna.tsinghua.edu.cn/bioconductor')" >> ${R_HOME}/etc/Rprofile.site

# clusterProfiler
# R -e "install.packages('igraph', repos='https://mirrors.tuna.tsinghua.edu.cn/CRAN/')"
install2.r -e -r https://mirrors.tuna.tsinghua.edu.cn/CRAN/ igraph
installBioc.r -e \
    Biostrings \
    org.Hs.eg.db \
    clusterProfiler
R -q -e "library(org.Hs.eg.db)"
R -q -e "library(clusterProfiler)"

# survminer -> nloptr -> cmake
apt-get update && apt-get -y install cmake

install2.r --error --skipinstalled -n 8 -r https://mirrors.tuna.tsinghua.edu.cn/CRAN/ \
    nloptr \
    survminer \
    ggbeeswarm \
    ggstatsplot \
    pheatmap
R -q -e "library(survminer)"
R -q -e "library(ggbeeswarm)"
R -q -e "library(ggstatsplot)"
R -q -e "library(pheatmap)"

installBioc.r -e -n 8 \
    limma \
    DESeq2 \
    GSVA \
    edgeR \
    maftools \
    ComplexHeatmap
R -q -e "library(DESeq2)"
R -q -e "library(edgeR)"
R -q -e "library(maftools)"
R -q -e "library(ComplexHeatmap)"

apt-get autoremove -y
apt-get autoclean -y
rm -rf /var/lib/apt/lists/*
