#!/bin/bash
set -e

UBUNTU_VERSION=${UBUNTU_VERSION:-$(lsb_release -sc)}
CRAN=${CRAN:-https://cran.r-project.org}
CRAN_SOURCE=${CRAN/"__linux__/$UBUNTU_VERSION/"/""}

function apt_install() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            apt-get update
        fi
        apt-get install -y --no-install-recommends "$@"
    fi
}

BUILDDEPS="libpcre2-dev \
    liblzma-dev \
    libbz2-dev \
    zlib1g-dev \
    libicu-dev"

apt_install ${BUILDDEPS}

Rscript -e "install.packages(c('littler', 'docopt'), repos='${CRAN_SOURCE}')"

ln -s ${R_HOME}/site-library/littler/examples/install2.r /usr/local/bin/install2.r
ln -s ${R_HOME}/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r
ln -s ${R_HOME}/site-library/littler/bin/r /usr/local/bin/r

if [ ! -d ${R_HOME}/site-library/littler ]; then
    echo "##### littler NOT installed #####"
    exit 1
fi

## Keep latest
pkg_ver=$(Rscript -e "cat(as.character(utils::packageVersion('littler')))")
if [ "$pkg_ver" == "0.3.15" ]; then
    ln -sf /build_scripts/bin/install2.r /usr/local/bin/install2.r
    echo "-- install2.r repalced --"
else
    echo "----- littler version: $pkg_ver -----"
fi

# Clean up
apt-get remove --purge -y ${BUILDDEPS}
apt-get autoremove -y
apt-get autoclean -y

cd /
rm -rf /tmp/*
rm -rf /var/lib/apt/lists/*

# Check the R info
echo -e "Check the littler info...\n"
r --version
echo -e "Check the R info...\n"
R -q -e "sessionInfo()"
echo -e "Setup R, done!"
