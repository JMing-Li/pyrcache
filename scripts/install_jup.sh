#!/bin/bash

set -e

python3 -m pip --no-cache-dir install wheel
## jupyterlab DEPS: json5 installation may be failed (latest setuptools/pip),
## use /usr/bin/pip to install first, then use pip in the VENV.
#python3 -m pip --no-cache-dir install json5

python3 -m pip --no-cache-dir install \
    'jupyterlab==3.4.3' \
    pandas \
    rpy2 \
    jupyterlab-lsp \
# pandas is the DEP of rpy2's rmagic

# install LSP servers for languages
python3 -m pip --no-cache-dir install 'python-lsp-server[all]'
R -e 'install.packages("languageserver")'

## Rkernal
apt-get update && apt-get install -y \
    libzmq3-dev \
    liblzma-dev \
    libbz2-dev
R --quiet -e "devtools::install_github('IRkernel/IRkernel')"
R --quiet -e "IRkernel::installspec(prefix='${PYTHON_VENV_PATH}')"


rm -rf /var/lib/apt/lists/*
rm -rf /tmp/downloaded_packages