FROM ubuntu:20.04
ENV R_VERSION=4.1.2 \
    R_HOME=/usr/local/lib/R \
    CRAN=https://packagemanager.rstudio.com/cran/__linux__/focal/latest
SHELL ["/bin/bash", "-c"]
WORKDIR /

COPY --chown=root:staff scripts/install_R.sh /build_scripts/install_R.sh
RUN chmod +x ./build_scripts/install_R.sh && \
    ./build_scripts/install_R.sh
ENV LANG=en_US.UTF-8
COPY --chown=root:staff scripts/install_littler.sh /build_scripts/install_littler.sh
COPY --chown=root:staff scripts/bin/install2.r /build_scripts/bin/
RUN chmod +x /build_scripts/bin/install2.r /build_scripts/install_littler.sh && \
    /build_scripts/install_littler.sh

ENV WORKON_HOME=/opt/venv \
    PYTHON_VENV_PATH=/opt/venv/reticulate \
    PATH=/opt/venv/reticulate/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
COPY --chown=root:staff scripts/install_python.sh /build_scripts/install_python.sh
COPY --chown=root:staff scripts/install_pyenv.sh /build_scripts/install_pyenv.sh
RUN chmod +x /build_scripts/install_python.sh /build_scripts/install_pyenv.sh && \
    /build_scripts/install_python.sh

ENV S6_VERSION=v2.1.0.2 \
    RSTUDIO_VERSION=2022.02.0+443 \
    DEFAULT_USER=rstudio \
    PATH=/usr/lib/rstudio-server/bin:/opt/venv/reticulate/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin/:/bin
COPY --chown=root:staff scripts/install_rstudio_DEPS.sh /build_scripts/install_rstudio_DEPS.sh
RUN chmod +x ./build_scripts/install_rstudio_DEPS.sh && \
    /build_scripts/install_rstudio_DEPS.sh

ENV TZ=Asia/Shanghai
COPY --chown=root:staff scripts/install_rstudio.sh /build_scripts/install_rstudio.sh
COPY --chown=root:staff scripts/default_user.sh  /build_scripts/
COPY --chown=root:staff scripts/init_set_env.sh /build_scripts/
COPY --chown=root:staff scripts/init_userconf.sh /build_scripts/
COPY --chown=root:staff scripts/pam-helper.sh /build_scripts/
RUN chmod +x ./build_scripts/install_rstudio.sh && \
    /build_scripts/install_rstudio.sh

COPY --chown=root:staff scripts/install_pandoc.sh /build_scripts/install_pandoc.sh
RUN chmod +x ./build_scripts/install_pandoc.sh  && \
    /build_scripts/install_pandoc.sh

COPY --chown=root:staff scripts/install_tidyverse_DEPS.sh /build_scripts/install_tidyverse_DEPS.sh
RUN chmod +x ./build_scripts/install_tidyverse_DEPS.sh  && \
    /build_scripts/install_tidyverse_DEPS.sh
COPY --chown=root:staff scripts/install_tidyverse.sh /build_scripts/install_tidyverse.sh
RUN chmod +x ./build_scripts/install_tidyverse.sh  && \
    /build_scripts/install_tidyverse.sh

ENV LD_LIBRARY_PATH=:/usr/local/lib/R/lib:/usr/local/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/jvm/java-11-openjdk-amd64/lib/server:
COPY --chown=root:staff scripts/install_jup.sh /build_scripts/install_jup.sh
RUN chmod +x /build_scripts/install_jup.sh && \
    /build_scripts/install_jup.sh

COPY --chown=root:staff scripts/setup_py.sh /build_scripts/setup_py.sh
RUN chmod +x /build_scripts/setup_py.sh && \
    /build_scripts/setup_py.sh
COPY --chown=root:staff scripts/setup_R.sh /build_scripts/setup_R.sh
RUN chmod +x /build_scripts/setup_R.sh && \
    /build_scripts/setup_R.sh

COPY --chown=root:staff scripts/setup_jup.sh scripts/init_set_jup.sh /build_scripts/
RUN chmod +x /build_scripts/setup_jup.sh && \
    /build_scripts/setup_jup.sh

EXPOSE 8787
EXPOSE 8888
CMD ["/init"]
