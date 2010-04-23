#!/bin/sh
PREFIX="/usr/local"

DEST_INSTALL_DIR="${PREFIX}/lib/trainsim"
BIN_DIR="${PREFIX}/bin"

# Install files
echo "Remove ${DEST_INSTALL_DIR}"
rm -r ${DEST_INSTALL_DIR}
rm "${BIN_DIR}/trainsim"
