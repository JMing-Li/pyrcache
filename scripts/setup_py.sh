#!/bin/bash
set -e

pip install --no-cache-dir \
    sqlalchemy \
    matplotlib \
    pillow \
    seaborn \
    sklearn \
    statannot \
    simplejson \
    psycopg2 \
    openpyxl \
    bioinfokit \
    gseapy==0.10.7 \
    jinja2 \
    plotnine \
    lifelines
