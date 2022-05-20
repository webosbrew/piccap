#!/bin/sh

# Toolchain params
TOOLCHAIN_DIR=${TOOLCHAIN_DIR:-$HOME/arm-webos-linux-gnueabi_sdk-buildroot}
TOOLCHAIN_ENV_FILE=${TOOLCHAIN_DIR}/environment-setup

EXEC_FILE=`readlink -f $0`
EXEC_DIR=`dirname ${EXEC_FILE}`
SERVICE_DIR=${EXEC_DIR}/servicenative

echo "* Using toolchain dir: ${TOOLCHAIN_DIR}"

echo "* Activating toolchain env"
source ${TOOLCHAIN_ENV_FILE} || exit 1

npm run clean || exit 1

echo ":: Frontend ::"
npm run build || exit 1

echo ":: Service ::"
npm run build-service || exit 1

echo ":: Copy native files (hyperion-webos) ::"
cp -r ./hyperion-webos/build/{hyperion-webos,*.so} ./servicenative/

echo ":: Ensure executable bit set ::"
for file in piccapautostart hyperion-webos
do
  FILE="${EXEC_DIR}/servicenative/${file}"
  echo "=> ${FILE}"
  chmod +x ${FILE}
done

echo ":: Package into IPK ::"
npm run package || exit 1