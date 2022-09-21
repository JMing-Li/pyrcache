#!/bin/bash
set -e
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --no-cache-dir notebook
# jupyter-client 7.3.5 requires tornado>=6.2
# pip install --force-reinstall tornado==6.1

# jupyter lab --ip='*' --port=8888 --no-browser --allow-root --notebook-dir=${NOTEBOOKDIR}
cp /build_scripts/init_set_jup.sh /etc/cont-init.d/03_set_jup

mkdir -p /etc/services.d/jupyterlab
cat > /etc/services.d/jupyterlab/run <<"EOF"
#!/usr/bin/with-contenv bash
## load /etc/environment vars first:
# for line in $( cat /etc/environment ) ; do export $line > /dev/null; done

/opt/venv/reticulate/bin/jupyter-lab
EOF

cat > /etc/services.d/jupyterlab/finish <<EOF
#!/bin/bash
echo '-------------jupyter lab STOPPED-------------'
/opt/venv/reticulate/bin/jupyter-lab stop 8888
sleep 3
EOF

# pycodestyle config
mkdir -p /root/.config/
cat > /root/.config/pycodestyle <<EOF
[pycodestyle]
ignore = E402, E703, E303, E231, E251
max-line-length = 150
EOF

# lintr config
cat > /root/.lintr <<EOF
linters: linters_with_defaults(
    line_length_linter = line_length_linter(length = 150L),
    commented_code_linter = NULL,
    single_quotes_linter = NULL,
    assignment_linter = NULL,
    T_and_F_symbol_linter = NULL,
    infix_spaces_linter = NULL
  )
EOF