#!/usr/bin/env bash

set -euo pipefail

PACKAGE=nginx_${NGINX_VERSION}_$(date +%Y.%m.%d).run

cp -f install.sh "${PACKAGE}"
cp -f distribution/nginx.* "${INSTALL_PATH}"
tar zcf ${PWD}/tmp.tar.gz -C ${INSTALL_PATH} .

LINES=$(wc -l "${PACKAGE}" | awk '{print $1 + 1}')

sed -i "s#_lines#${LINES}#g" "${PACKAGE}"
sed -i "s#_prefix#${PREFIX}#g" "${PACKAGE}"

cat tmp.tar.gz >> "${PACKAGE}" \
  && rm tmp.tar.gz \
  && chmod +x "${PACKAGE}"
