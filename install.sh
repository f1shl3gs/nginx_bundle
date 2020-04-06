#!/usr/bin/env bash

set -euo pipefail

if [[ $UID -ne 0 ]]; then
  echo "superuser privileges are required to run"
  exit 1
fi

# the value will be replaced when build
LINES=_lines
PREFIX=_prefix

# paths for build
TEMP_DIR=/tmp/nginx
BINARY=${PREFIX}/sbin/nginx
PID_FILE=${PREFIX}/logs/nginx.pid

# init system
INIT_SECRIPT_PATH=/etc/init.d/nginx
SERVICE_UNIT_PATH=/lib/systemd/system/nginx.service

function decompress() {
  mkdir -p ${TEMP_DIR}
  tail -n +${LINES} "$0" > ${TEMP_DIR}/temp.tar.gz
  tar zxfv ${TEMP_DIR}/tmp.tar.gz -C ${TEMP_DIR}
}

function prepare() {
  test -d "${PREFIX}" || mkdir -p ${PREFIX}
  test -d "${PREFIX}/sbin" || mkdir -p ${PREFIX}/sbin
  test -d "${PREFIX}/"
}

function install() {
  cp -r ${TEMP_DIR}/${PREFIX}/* ${PREFIX}
}

function update() {
  # backup the old binary first
  test ! -f ${BINARY} || mv ${BINARY} ${BINARY}.old
  # cp the new one
  cp ${TEMP_DIR}/sbin/nginx ${BINARY}

  # check current config file
  ${BINARY} -t

  # start upgrading
  echo "start upgrading..."
  kill -USR2 $(cat ${PID_FILE})
  sleep 1
  test -f ${PID_FILE}.oldbin

  kill -QUIT $(cat ${PID_FILE}.oldbin)

  echo "upgrade success"
}

function post() {
  # install service control files
  if command -v systemctl &> /dev/null; then
    # EL7
    cp ${TEMP_DIR}/nginx.service  ${SERVICE_UNIT_PATH}
    systemctl daemon-reload
    systemctl enable nginx
  else
    # EL6
    cp -f ${TEMP_DIR}/nginx.init ${INIT_SECRIPT_PATH}
    chmod +x ${INIT_SECRIPT_PATH}
    chkconfig --add nginx
  fi
}

function main() {
  prepare

  if [[ -f ${BINARY} ]]; then
    update
    echo "update done"
  else
    install
  fi

  post
}

main

exit 0
