# paths for build and test
PREFIX   		:= /usr/local/nginx
BUILD_PATH     	:= ${PWD}/build
LIBRARY_PATH 	:= ${PWD}/library
SOURCE_PATH  	:= ${PWD}/source
PATCHES_PATH 	:= ${PWD}/patches
NGX_LUALIB_PATH := ${PREFIX}/lualib
INSTALL_PATH    := ${PWD}/install

# options for build nginx
NGX_CC_OPT 	:= "-O2"
NGX_LD_OPT	:= "-Wl,-rpath,${LIBRARY_PATH}/luajit/lib"
CPUS        ?= $(shell nproc)

# version of dependencies
ZLIB_VERSION    					:= 1.2.11
PCRE_VERSION    					:= 8.44
OPENSSL_VERSION 					:= 1_1_1d
NGINX_VERSION   					:= 1.16.1
LUAJIT_VERSION  					:= 2.1-20190507
NGX_LUA_MODULE_VERSION 				:= 0.10.15
NGX_UPSTREAM_CHECK_MODULE_VERSION 	:= master
NGX_LUA_WAF_VERSION					:= 0.7.2
NGX_UPSYNC_MODULE_VERSION			:= 2.1.2
NGX_DEVEL_KIT_VERSION 				:= 0.3.1
NGX_HEADER_MORE_VERSION 			:= 0.33
# lualib
LUA_RESTY_CORE_VERSION 				:= 0.1.17
LUA_RESTY_LRUCACHE_VERSION 			:= 0.09


# dependencies urls
ZLIB_SOURCE 						:= https\://github.com/madler/zlib/archive/v${ZLIB_VERSION}.zip
PCRE_SOURCE     					:= https\://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.zip
NGINX_SOURCE    					:= https\://github.com/nginx/nginx/archive/release-${NGINX_VERSION}.zip
OPENSSL_SOURCE  					:= https\://github.com/openssl/openssl/archive/OpenSSL_${OPENSSL_VERSION}.zip
LUAJIT_SOURCE  						:= https\://github.com/openresty/luajit2/archive/v${LUAJIT_VERSION}.zip
NGX_LUA_WAF_SOURCE     				:= https\://github.com/loveshell/ngx_lua_waf/archive/v${NGX_LUA_WAF_VERSION}.zip
NGX_LUA_MODULE_SOURCE  				:= https\://github.com/openresty/lua-nginx-module/archive/v${NGX_LUA_MODULE_VERSION}.zip
NGX_UPSTREAM_CHECK_MODULE_SOURCE 	:= https\://github.com/xiaokai-wang/nginx_upstream_check_module/archive/${NGX_UPSTREAM_CHECK_MODULE_VERSION}.zip
NGX_UPSYNC_MODULE_SOURCE 			:= https\://github.com/weibocom/nginx-upsync-module/archive/v${NGX_UPSYNC_MODULE_VERSION}.zip
NGX_DEVEL_KIT_SOURCE                := https\://github.com/vision5/ngx_devel_kit/archive/v${NGX_DEVEL_KIT_VERSION}.zip
NGX_HEADER_MORE_SOURCE 				:= https\://github.com/openresty/headers-more-nginx-module/archive/v${NGX_HEADER_MORE_VERSION}.zip
LUA_RESTY_CORE_SOURCE				:= https\://github.com/openresty/lua-resty-core/archive/v${LUA_RESTY_CORE_VERSION}.zip
LUA_RESTY_LRUCACHE_SOURCE 			:= https\://github.com/openresty/lua-resty-lrucache/archive/v${LUA_RESTY_LRUCACHE_VERSION}.zip

# list of resource to build nginx
RESOURCES := \
	${ZLIB_SOURCE} \
    ${PCRE_SOURCE} \
    ${NGINX_SOURCE} \
    ${OPENSSL_SOURCE} \
    ${LUAJIT_SOURCE} \
    ${NGX_LUA_WAF_SOURCE} \
    ${NGX_LUA_MODULE_SOURCE} \
    ${NGX_UPSTREAM_CHECK_MODULE_SOURCE} \
    ${NGX_UPSYNC_MODULE_SOURCE} \
    ${NGX_DEVEL_KIT_SOURCE}	\
    ${NGX_HEADER_MORE_SOURCE} \
    ${LUA_RESTY_CORE_SOURCE} \
    ${LUA_RESTY_LRUCACHE_SOURCE}

.PHONY: luajit build clean

# /home/fishlegs/Downloads/openresty-1.15.8.3/build/luajit-root/home/fishlegs/Downloads/openresty-1.15.8.3/test/luajit/lib

# build: export LUAJIT_LIB=/home/fishlegs/Downloads/openresty-1.15.8.3/build/luajit-root/home/fishlegs/Downloads/openresty-1.15.8.3/test/luajit/lib
# build: export LUAJIT_INC=/home/fishlegs/Downloads/openresty-1.15.8.3/build/luajit-root/home/fishlegs/Downloads/openresty-1.15.8.3/test/luajit/include/luajit-2.1

build: export LUAJIT_LIB=${LIBRARY_PATH}/luajit/lib
build: export LUAJIT_INC=${LIBRARY_PATH}/luajit/include/luajit-2.1
build: patch luajit
	cd ${BUILD_PATH}/nginx-release-${NGINX_VERSION} && ./auto/configure \
		--with-pcre=${BUILD_PATH}/pcre-${PCRE_VERSION} \
		--with-pcre-jit \
		--with-zlib=${BUILD_PATH}/zlib-${ZLIB_VERSION} \
		--with-openssl=${BUILD_PATH}/openssl-OpenSSL_${OPENSSL_VERSION} \
		--prefix=${PREFIX} \
		--with-cc-opt=${NGX_CC_OPT} \
		--with-ld-opt=${NGX_LD_OPT} \
		--with-http_ssl_module \
		--with-http_v2_module \
		--with-http_stub_status_module \
		--with-http_realip_module \
		--with-http_addition_module \
		--with-http_auth_request_module \
		--with-http_secure_link_module \
		--with-http_random_index_module \
		--with-http_gzip_static_module \
		--with-http_gunzip_module \
		--with-http_sub_module \
		--without-mail_pop3_module \
		--without-mail_imap_module \
		--without-mail_smtp_module \
		--with-stream \
		--with-stream_ssl_module \
		--with-stream_ssl_preread_module \
		--without-select_module \
		--without-poll_module \
		--with-file-aio \
		--with-threads \
		--with-compat \
		--add-module=${BUILD_PATH}/ngx_devel_kit-${NGX_DEVEL_KIT_VERSION} \
		--add-module=${BUILD_PATH}/lua-nginx-module-${NGX_LUA_MODULE_VERSION} \
		--add-module=${BUILD_PATH}/nginx_upstream_check_module-${NGX_UPSTREAM_CHECK_MODULE_VERSION} \
		--add-module=${BUILD_PATH}/headers-more-nginx-module-${NGX_HEADER_MORE_VERSION} \
		--add-module=${BUILD_PATH}/nginx-upsync-module-${NGX_UPSYNC_MODULE_VERSION} && make -j${CPUS} && make install DESTDIR=${INSTALL_PATH}
	# install waf module
	cp -r ${BUILD_PATH}/ngx_lua_waf-${NGX_LUA_WAF_VERSION} ${INSTALL_PATH}/${PREFIX}/conf/waf
	# install necessary lua libraries
	cd ${BUILD_PATH}/lua-resty-core-${LUA_RESTY_CORE_VERSION} && make install LUA_LIB_DIR=${INSTALL_PATH}/${NGX_LUALIB_PATH}
	cd ${BUILD_PATH}/lua-resty-lrucache-${LUA_RESTY_LRUCACHE_VERSION} && make install LUA_LIB_DIR=${INSTALL_PATH}/${NGX_LUALIB_PATH}
	# set lua search path
	sed -i '/octet-stream;/a\\n\ \ \ \ # set search paths for Lua external libraries\n\ \ \ \ lua_package_path ${NGX_LUALIB_PATH}/?.lua;\n\ \ \ \ lua_package_cpath ${NGX_LUALIB_PATH}/?.so;' ${INSTALL_PATH}/${PREFIX}/conf/nginx.conf
	# package
	PREFIX=${PREFIX} NGINX_VERSION=${NGINX_VERSION} INSTALL_PATH=${INSTALL_PATH} bash ./package.sh

$(RESOURCES):
	wget -q -P ${SOURCE_PATH} $@

unzip: download
	@for FILE in ${SOURCE_PATH}/*; do unzip $${FILE} -d ${BUILD_PATH}; done

download: export MAKEFLAGS="-j${CPUS}"
download: $(RESOURCES)

patch: patches/check_1.16.1+.patch unzip
	cd ${BUILD_PATH}/nginx-release-${NGINX_VERSION} && patch -p1 < ${PATCHES_PATH}/check_1.16.1+.patch && touch .patch

# XCFLAGS='-DLUAJIT_ENABLE_LUA52COMPAT -DLUAJIT_ENABLE_GC64 -msse4.2'
luajit: unzip
	cd ${BUILD_PATH}/luajit2-${LUAJIT_VERSION} && \
		make install -j${CPUS} PREFIX=${LIBRARY_PATH}/luajit XCFLAGS='-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT -DLUAJIT_ENABLE_GC64 -msse4.2'

clean:
	rm -rf ${BUILD_PATH}
	rm -rf ${LIBRARY_PATH}
	rm -rf ${SOURCE_PATH}
	rm -rf ${INSTALL_PATH}
	rm -f nginx_*.run
