#!/usr/bin/with-contenv bash

set -e
NOTEBOOKDIR=${NOTEBOOKDIR:-/home/rstudio}

hashed_pw=$(/opt/venv/reticulate/bin/python -c "from notebook.auth import passwd; print(passwd('$PASSWORD'))")
mkdir -p /root/.jupyter
cat > /root/.jupyter/jupyter_server_config.json <<EOF
{
  "ServerApp": {
    "password": "$hashed_pw"
  },
  "Completer": {
    "use_jedi": true
  }
}
EOF

cat > /root/.jupyter/jupyter_lab_config.py <<EOF
c.ServerApp.allow_root = True
c.ServerApp.open_browser = False
c.ServerApp.port = 8888
c.ServerApp.root_dir = "$NOTEBOOKDIR"
c.ServerApp.ip = '*'
EOF

# c.ServerApp.kernel_manager_class = 'jupyter_server.services.kernels.kernelmanager.AsyncMappingKernelManager'
# default: 'jupyter_server.services.kernels.kernelmanager.MappingKernelManager'

# c.ServerApp.iopub_msg_rate_limit = 10000
# c.ServerApp.rate_limit_window = 10