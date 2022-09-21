#!/bin/bash
set -e

### Sets up S6 supervisor

S6_VERSION=${1:-${S6_VERSION:-"v2.1.0.2"}}
S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ARCH=$(dpkg --print-architecture)
DOWNLOAD_FILE=s6-overlay-${ARCH}.tar.gz

## Set up S6 init system
wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/${S6_VERSION}/$DOWNLOAD_FILE
## need the modified double tar now, see https://github.com/just-containers/s6-overlay/issues/288
tar hzxf /tmp/$DOWNLOAD_FILE -C / --exclude=usr/bin/execlineb
tar hzxf /tmp/$DOWNLOAD_FILE -C /usr ./bin/execlineb && $_clean


## Download RStudio Server for Ubuntu 18+
DOWNLOAD_FILE=rstudio-server.deb

if [ "$RSTUDIO_VERSION" = "latest" ]; then
  RSTUDIO_VERSION="stable"
fi

if [ "$RSTUDIO_VERSION" = "stable" ] || [ "$RSTUDIO_VERSION" = "preview" ] || [ "$RSTUDIO_VERSION" = "daily" ]; then
  wget "https://rstudio.org/download/latest/${RSTUDIO_VERSION}/server/bionic/rstudio-server-latest-${ARCH}.deb" -O "$DOWNLOAD_FILE"
else
  wget "https://download2.rstudio.org/server/bionic/${ARCH}/rstudio-server-${RSTUDIO_VERSION/"+"/"-"}-${ARCH}.deb" -O "$DOWNLOAD_FILE" \
  || wget "https://s3.amazonaws.com/rstudio-ide-build/server/bionic/${ARCH}/rstudio-server-${RSTUDIO_VERSION/"+"/"-"}-${ARCH}.deb" -O "$DOWNLOAD_FILE"
fi

dpkg -i "$DOWNLOAD_FILE"  ## installed to /usr/lib/rstudio-server/
rm "$DOWNLOAD_FILE"

rm -f /var/lib/rstudio-server/secure-cookie-key

## RStudio wants an /etc/R, will populate from $R_HOME/etc
mkdir -p /etc/R
echo "PATH=${PATH}" >> ${R_HOME}/etc/Renviron.site

## Make RStudio compatible with case when R is built from source
## (and thus is at /usr/local/bin/R), because RStudio doesn't obey
## path if a user apt-get installs a package
R_BIN=$(which R)
echo "rsession-which-r=${R_BIN}" > /etc/rstudio/rserver.conf
## use more robust file locking to avoid errors when using shared volumes:
echo "lock-type=advisory" > /etc/rstudio/file-locks

## Prepare optional configuration file to disable authentication
## To de-activate authentication, `disable_auth_rserver.conf` script
## will just need to be overwrite /etc/rstudio/rserver.conf.
## This is triggered by an env var in the user config
cp /etc/rstudio/rserver.conf /etc/rstudio/disable_auth_rserver.conf
echo "auth-none=1" >> /etc/rstudio/disable_auth_rserver.conf

## Set up RStudio init scripts
mkdir -p /etc/services.d/rstudio

# s6-overlay shebang
cat > /etc/services.d/rstudio/run <<EOF
#!/usr/bin/with-contenv bash
## load /etc/environment vars first:
for line in $( cat /etc/environment ) ; do export $line > /dev/null; done
exec /usr/lib/rstudio-server/bin/rserver --server-daemonize 0
EOF

echo '#!/bin/bash
rstudio-server stop' \
> /etc/services.d/rstudio/finish

# If CUDA enabled, make sure RStudio knows (config_cuda_R.sh also handles)
if [ ! -z "$CUDA_HOME" ]; then
  sed -i '/^rsession-ld-library-path/d' /etc/rstudio/rserver.conf
  echo "rsession-ld-library-path=$LD_LIBRARY_PATH" >> /etc/rstudio/rserver.conf
fi

# Log to stderr
LOGGING="[*]
log-level=warn
logger-type=syslog
"
echo "$LOGGING" > /etc/rstudio/logging.conf

# Set up default user
chmod +x /build_scripts/default_user.sh
/build_scripts/default_user.sh

# Install user config initiation script
# ----------TODO----------
cp /build_scripts/init_set_env.sh /etc/cont-init.d/01_set_env
cp /build_scripts/init_userconf.sh /etc/cont-init.d/02_userconf
cp /build_scripts/pam-helper.sh /usr/lib/rstudio-server/bin/pam-helper
