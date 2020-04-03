#!/usr/bin/env bash

set -euo pipefail

PACKAGES=packages
TEMP=temp

function download_and_unpack() {
  local SOURCE=${1}
  local NAME=${2}
}

function luajit() {
  local TARGET=${PACKAGES}/luajit.zip
  wget https://github.com/LuaJIT/LuaJIT/archive/v2.0.5.zip -O ${TARGET}
  unzip ${TARGET} -d ${TEMP}
}

function nginx() {
  local TARGET=${PACKAGES}/nginx.zip
  wget https://github.com/nginx/nginx/archive/release-1.16.1.zip -O ${TARGET}
  unzip ${TARGET} -d ${TEMP}
}

function openssl() {
  local TARGET=${PACKAGES}/openssl.zip
  wget https://github.com/openssl/openssl/archive/OpenSSL_1_1_1d.zip -O ${TARGET}
  unzip ${TARGET} -d ${TEMP}
}

function pcre() {
  local TARGET=${PACKAGES}/pcre.zip
  wget https://ftp.pcre.org/pub/pcre/pcre-8.44.zip -O ${TARGET}
  unzip ${TARGET} -d ${TEMP}
}

function ngx_lua_module() {
  local TARGET=${PACKAGES}/ngx_lua_module.zip
  wget https://github.com/openresty/lua-nginx-module/archive/v0.10.15.zip -O ${TARGET}
  unzip ${TARGET} -d ${TEMP}
}

function ngx_http_upstream_check_module() {
  local TARGET=${PACKAGES}/ngx_http_upstream_check_module.zip
  wget https://github.com/yaoweibin/nginx_upstream_check_module/archive/master.zip -O ${TARGET}
  unzip ${TARGET} -d ${TEMP}
}

function ngx_upsync_module() {
  local TARGET=${PACKAGES}/ngx_upsync_module.zip
  wget https://github.com/weibocom/nginx-upsync-module/archive/v2.1.2.zip -O ${TARGET}
  unzip ${TARGET} -d ${TEMP}
}

function main() {
  # create dirs if needed
  if [[ ! -d ${PACKAGES} ]]; then
    mkdir -p ${PACKAGES}
  fi

  if [[ ! -d ${TEMP} ]]; then
    mkdir -p ${TEMP}
  fi

  # download and unpack
  nginx
  openssl
  pcre
  luajit
  ngx_lua_module
  ngx_http_upstream_check_module
  ngx_upsync_module
}

main
