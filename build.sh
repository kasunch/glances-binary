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
REQUIREMENTS_FILE="${BUILD_DIR}/requirements.txt"
RELEASE_NOTES_FILE="${BUILD_DIR}/release-notes.txt"

mkdir -p "${SCRIPT_DIR_FULL}"
mkdir -p "${PYTHON_VENV_DIR}"

python -m venv "${PYTHON_VENV_DIR}"
PATH="${PYTHON_VENV_DIR}/bin:${PATH}"

pip install --no-cache-dir glances[all]

pip freeze >"${REQUIREMENTS_FILE}"

pip install --no-cache-dir pyinstaller

pyinstaller_cmd="pyinstaller --onefile $(which glances) "
pyinstaller_cmd+="--add-data ${PYTHON_VENV_DIR}/lib/python3.11/site-packages/glances:glances "

while IFS= read -r package; do
    package_name=$(echo "${package}" | cut -d'=' -f1)
    pyinstaller_cmd+="--hidden-import=${package_name} "
done <"${REQUIREMENTS_FILE}"

echo "Running command: ${pyinstaller_cmd}"

cd ${BUILD_DIR} && ${pyinstaller_cmd}

glances --version | grep -v "Log file" >"${RELEASE_NOTES_FILE}"
