#!/bin/bash

set -e

## build ARGs
NCPUS=${NCPUS:--1}

install2.r --error --skipinstalled \
    tidyverse \
    devtools \
    rmarkdown \
    BiocManager \
    vroom \
    gert

# ## dplyr database backends
# install2.r --error --skipinstalled -n "$NCPUS" \
#     arrow \
#     dbplyr \
#     DBI \
#     dtplyr \
#     duckdb \
#     nycflights13 \
#     Lahman \
#     RMariaDB \
#     RPostgres \
#     RSQLite \
#     fst

## a bridge to far? -- brings in another 60 packages
# install2.r --error --skipinstalled -n "$NCPUS" tidymodels

# Clean up
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/downloaded_packages

# Check the tidyverse core packages' version
echo -e "Check the tidyverse package...\n"

R -q -e "library(tidyverse)"

echo -e "\nInstall tidyverse package, done!"
