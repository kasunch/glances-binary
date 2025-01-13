#!/bin/bash

SCRIPT_NAME_FULL=$(basename "${0}")
SCRIPT_NAME_BASE="${SCRIPT_NAME_FULL%%.*}"
SCRIPT_FILE_FULL=$(readlink -f "${0}")
SCRIPT_FILE_BASE="${SCRIPT_FILE_FULL%%.*}"
SCRIPT_DIR=$(dirname "${SCRIPT_FILE_FULL}")
SCRIPT_DIR_FULL=$(readlink -f "${SCRIPT_DIR}")

docker run -it --rm \
    -v "${SCRIPT_DIR_FULL}":/work \
    --workdir /work \
    pyinstaller \
    "/work/build.sh"
