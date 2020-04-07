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

function pre_install() {
  # decompress
  mkdir -p ${TEMP_DIR}
  tail -n +${LINES} "$0" > ${TEMP_DIR}/temp.tar.gz
  tar zxf ${TEMP_DIR}/temp.tar.gz -C ${TEMP_DIR}

  test -d "${PREFIX}" || mkdir -p ${PREFIX}
}

function install() {
  cp -r ${TEMP_DIR}${PREFIX}/* ${PREFIX}
}

function update() {
  # backup the old binary first
  test ! -f ${BINARY} || mv ${BINARY} ${BINARY}.old
  # cp the new one
  cp ${TEMP_DIR}${PREFIX}/sbin/nginx ${BINARY}

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

function post_install() {
  # install service control files
  if command -v systemctl &> /dev/null; then
    # EL7 or EL8
    cp ${TEMP_DIR}/nginx.service  ${SERVICE_UNIT_PATH}
    systemctl daemon-reload
    systemctl enable nginx
  else
    # EL6
    cp -f ${TEMP_DIR}/nginx.init ${INIT_SECRIPT_PATH}
    chmod +x ${INIT_SECRIPT_PATH}
    chkconfig --add nginx
  fi

  # sbin
  ln -sf ${PREFIX}/sbin/nginx  /usr/sbin/nginx
}

function main() {
  pre_install

  if [[ -f ${BINARY} ]]; then
    update
    echo "update nginx success"
  else
    echo "install nginx success"
    install
  fi

  post_install
}

main

exit 0
