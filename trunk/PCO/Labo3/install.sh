#!/bin/sh
PREFIX="/usr/local"

DEST_INSTALL_DIR="${PREFIX}/lib/trainsim"
BIN_DIR="${PREFIX}/bin"

# Install files
echo "Install in ${DEST_INSTALL_DIR}"
mkdir "${DEST_INSTALL_DIR}"
cp -r "auxfiles" "${DEST_INSTALL_DIR}"
cp -r "bin" "${DEST_INSTALL_DIR}"
echo >> "${DEST_INSTALL_DIR}/bin/trai.txt"
chmod 666 "${DEST_INSTALL_DIR}/bin/trai.txt"

# Install lauching script

echo  "#!/bin/sh" > "${BIN_DIR}/trainsim"
echo "cd ${DEST_INSTALL_DIR}/auxfiles" >> "${BIN_DIR}/trainsim"
echo "${DEST_INSTALL_DIR}/bin/trainsim" >> "${BIN_DIR}/trainsim"
chmod +x "${BIN_DIR}/trainsim"
