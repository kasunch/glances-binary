#!/bin/bash

SCRIPT_NAME_FULL=$(basename "${0}")
SCRIPT_NAME_BASE="${SCRIPT_NAME_FULL%%.*}"
SCRIPT_FILE_FULL=$(readlink -f "${0}")
SCRIPT_FILE_BASE="${SCRIPT_FILE_FULL%%.*}"
SCRIPT_DIR=$(dirname "${SCRIPT_FILE_FULL}")
SCRIPT_DIR_FULL=$(readlink -f "${SCRIPT_DIR}")

PYTHON_VENV="build-env"
BUILD_DIR="${SCRIPT_DIR_FULL}/build"
PYTHON_VENV_DIR="${BUILD_DIR}/venv/${PYTHON_VENV}"
HIDDEN_IMPORTS_FILE="${SCRIPT_DIR_FULL}/hidden-imports.txt"
VERSION_FILE="${BUILD_DIR}/version.txt"

mkdir -p "${SCRIPT_DIR_FULL}"
mkdir -p "${PYTHON_VENV_DIR}"

python -m venv "${PYTHON_VENV_DIR}"
PATH="${PYTHON_VENV_DIR}/bin:${PATH}"

pip install --no-cache-dir pyinstaller glances[all]

pyinstaller_cmd="pyinstaller --onefile $(which glances) "
pyinstaller_cmd+="--add-data ${PYTHON_VENV_DIR}/lib/python3.11/site-packages/glances:glances "

while IFS= read -r module || [[ -n "${module}" ]]; do
    module_name=$(echo "${module}" | xargs)
    pyinstaller_cmd+="--hidden-import=${module_name} "
done <"${HIDDEN_IMPORTS_FILE}"

echo "Running command: ${pyinstaller_cmd}"

cd ${BUILD_DIR} && ${pyinstaller_cmd}

glances --version | grep -v "Log file" >"${VERSION_FILE}"
