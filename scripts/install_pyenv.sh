#!/bin/bash

## Install pyenv, to facilitate installation of different python versions
## Allows users to do things like:
##     pyenv install 3.7.9 # install python 3.7.9; e.g. for tensorflow 1.15.x
##     pyenv global 3.7.9  # activate as the default python
##

set -e

PYTHON_CONFIGURE_OPTS=${PYTHON_CONFIGURE_OPTS:-"--enable-shared"}

echo "PYTHON_CONFIGURE_OPTS=${PYTHON_CONFIGURE_OPTS}" >>"${R_HOME}/etc/R_environ"

## /opt/venv/reticulate/bin/python3
python3 -m pip --no-cache-dir install pipenv
# ==2022.4.21  
# --upgrade --ignore-installed

curl https://pyenv.run | bash
mv /root/.pyenv /opt/pyenv

# WARNING: seems you still have not added 'pyenv' to the load path.
# # Load pyenv automatically by appending
# # the following to
# ~/.bash_profile if it exists, otherwise ~/.profile (for login shells)
# and ~/.bashrc (for interactive shells) :
# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"
# # Restart your shell for the changes to take effect.
# # Load pyenv-virtualenv automatically by adding
# # the following to ~/.bashrc:
# eval "$(pyenv virtualenv-init -)"

# pipenv requires ~/.local/bin to be on the path...
echo "PATH=/opt/pyenv/bin:~/.local/bin:$PATH" >>"${R_HOME}/etc/Renviron.site"
cat >>/etc/bash.bashrc <<'EOF'
PATH=/opt/pyenv/bin:~/.local/bin:$PATH
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"
EOF
