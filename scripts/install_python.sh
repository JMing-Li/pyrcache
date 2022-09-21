#!/bin/bash
set -e

# python3 already installed when installing dependencies of devscripts

WORKON_HOME=${WORKON_HOME:-/opt/venv}
PYTHON_VENV_PATH=${PYTHON_VENV_PATH:-${WORKON_HOME}/reticulate}
RETICULATE_MINICONDA_ENABLED=${RETICULATE_MINICONDA_ENABLED:-FALSE}

function apt_install() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            echo '----- update ----'
            apt-get update
        fi
        apt-get install -y --no-install-recommends "$@"
    else
        echo "---- skip $@ ----"
    fi

}

apt_install \
    git \
    libpng-dev \
    libpython3-dev \
    python3-dev \
    python3-pip \
    python3-virtualenv \
    python3-venv \
    swig \
    curl

# upgrade packages in /usr/bin/pip3, NOT in VENV (venv not created yet).
python3 -m pip --no-cache-dir install --upgrade \
    pip==22.0.4 \
    setuptools==62.1.0 \
    virtualenv==20.14.1

mkdir -p "${WORKON_HOME}"
python3 -m venv "${PYTHON_VENV_PATH}"

install2.r --error --skipinstalled -n 1 reticulate

## Ensure RStudio inherits this env var
cat >>"${R_HOME}/etc/Renviron.site" <<EOF

WORKON_HOME=${WORKON_HOME}
RETICULATE_MINICONDA_ENABLED=${RETICULATE_MINICONDA_ENABLED}
EOF

## symlink these so that these are available when switching to a new venv
## -f check for file, -L for link, -e for either
if [ ! -e /usr/local/bin/python ]; then
    ln -s "$(which python3)" /usr/local/bin/python
fi

if [ ! -e /usr/local/bin/pip ]; then
    ln -s "${PYTHON_VENV_PATH}/bin/pip" /usr/local/bin/pip
fi

if [ ! -e /usr/local/bin/virtualenv ]; then
    ln -s "${PYTHON_VENV_PATH}/bin/virtualenv" /usr/local/bin/virtualenv
fi
## '/usr/local/bin/pip' already exists after running 'python3 -m pip install --upgrade pip'.
## However PATH was set to 'PATH=/opt/venv/reticulate/bin...' in Dockerfile. So pip was 
## redirected to '/opt/venv/reticulate/bin/pip' anyway.

## From now on, 'python3 -m pip' installs packages to /opt/venv/reticulate !

## Allow staff-level users to modify the shared environment
chown -R :staff "${WORKON_HOME}"
chmod g+wx "${WORKON_HOME}"
chown :staff "${PYTHON_VENV_PATH}"

## Packages of /usr/bin/pip got upgraded, while those in the newly created VENV didn't yet.
## Upgrade/install packages of pip in the VENV.
python3 -m pip --no-cache-dir install --upgrade \
    pip==22.0.4 \
    setuptools==62.1.0 \
    virtualenv==20.14.1

## Enable pyenv
/build_scripts/install_pyenv.sh

# Clean up
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/downloaded_packages

strip /usr/local/lib/R/site-library/*/libs/*.so
