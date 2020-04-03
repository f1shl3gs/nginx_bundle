PREFIX   	 := /usr/local/nginx
TEST_PATH    := ${PWD}/test
BUILD_PATH   := ${PWD}/build
LIBRARY_PATH := ${PWD}/library

# version
ZLIB_VERSION    					:= 1.2.11
PCRE_VERSION    					:= 8.44
OPENSSL_VERSION 					:= 1_1_1d
NGINX_VERSION   					:= 1.16.1
LUAJIT_VERSION  					:= 2.0.5
NGX_LUA_MODULE_VERSION 				:= 0.10.15
NGX_UPSTREAM_CHECK_MODULE_VERSION 	:= master
NGX_LUA_WAF_VERSION					:= 0.7.2
NGX_UPSYNC_MODULE_VERSION			:= 2.1.2

# urls
ZLIB_SOURCE 						:= https://github.com/madler/zlib/archive/v${ZLIB_VERSION}.zip
PCRE_SOURCE     					:= https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.zip
NGINX_SOURCE    					:= https://github.com/nginx/nginx/archive/release-${NGINX_VERSION}.zip
OPENSSL_SOURCE  					:= https://github.com/openssl/openssl/archive/OpenSSL_${OPENSSL_VERSION}.zip
LUAJIT_SOURCE  						:= https://github.com/LuaJIT/LuaJIT/archive/v${LUAJIT_VERSION}.zip
NGX_LUA_WAF_SOURCE     				:= https://github.com/loveshell/ngx_lua_waf/archive/v${NGX_LUA_WAF_VERSION}.zip
NGX_LUA_MODULE_SOURCE  				:= https://github.com/openresty/lua-nginx-module/archive/v${NGX_LUA_MODULE_VERSION}.zip
NGX_UPSTREAM_CHECK_MODULE_SOURCE 	:= https://github.com/yaoweibin/nginx_upstream_check_module/archive/${NGX_UPSTREAM_CHECK_MODULE_VERSION}.zip
NGX_UPSYNC_MODULE_SOURCE 			:= https://github.com/weibocom/nginx-upsync-module/archive/v${NGX_UPSYNC_MODULE_VERSION}.zip

define download
	wget ${1} -O tmp.zip && unzip tmp.zip -d ${BUILD_PATH} && rm tmp.zip
endef

.PHONY: .luajit build

clean:
	rm -rf ${TEST_PATH}
	rm -rf ${BUILD_PATH}
	rm -rf ${LIBRARY_PATH}
	rm -f .resource
	rm -f .patch

resource:
	$(call download,${ZLIB_SOURCE})
	$(call download,${PCRE_SOURCE})
	$(call download,${NGINX_SOURCE})
	$(call download,${OPENSSL_SOURCE})
	$(call download,${LUAJIT_SOURCE})
	$(call download,${NGX_LUA_WAF_SOURCE})
	$(call download,${NGX_LUA_MODULE_SOURCE})
	$(call download,${NGX_UPSTREAM_CHECK_MODULE_SOURCE})
	$(call download,${NGX_UPSYNC_MODULE_SOURCE})
	touch .resource

.patch:
	cd ${BUILD_PATH}/nginx-release-${NGINX_VERSION} && patch -p1 < ../nginx_upstream_check_module-master/check_1.16.1+.patch && touch .patch

.luajit:
	cd ${BUILD_PATH}/LuaJIT-${LUAJIT_VERSION} && make install PREFIX=${LIBRARY_PATH}/luajit

build: export LUAJIT_LIB=${LIBRARY_PATH}/luajit/lib
build: export LUAJIT_INC=${LIBRARY_PATH}/luajit/include/luajit-2.0
build:
	cd ${BUILD_PATH}/nginx-release-${NGINX_VERSION} && ./auto/configure \
		--with-pcre-jit \
		--with-pcre=${BUILD_PATH}/pcre-${PCRE_VERSION} \
		--with-zlib=${BUILD_PATH}/zlib-${ZLIB_VERSION} \
		--with-stream \
		--with-openssl=${BUILD_PATH}/openssl-OpenSSL_${OPENSSL_VERSION} \
		--with-http_ssl_module \
		--prefix=${TEST_PATH} \
		--with-ld-opt="-Wl,-rpath,${LIBRARY_PATH}/luajit/lib" \
		--add-module=${BUILD_PATH}/lua-nginx-module-${NGX_LUA_MODULE_VERSION} \
		--add-module=${BUILD_PATH}/nginx_upstream_check_module-${NGX_UPSTREAM_CHECK_MODULE_VERSION} \
		--add-module=${BUILD_PATH}/nginx-upsync-module-${NGX_UPSYNC_MODULE_VERSION} && make -j16 install

e2e:
	echo e2e

docker:
	cd