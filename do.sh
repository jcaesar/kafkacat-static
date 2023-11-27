#!/usr/bin/env bash

set -eu

ver=$(sed -rn "H;1h;\$!d;x;s/^.*project\([^)]*kafkacat[^)]*version:[ \t]*'([^']+)'.*$/\1/p" meson.build)
test -f src-$ver.tgz || wget https://github.com/edenhill/kafkacat/archive/$ver.tar.gz -Osrc-$ver.tgz
sha256sum --ignore-missing -c <sha256 || ( rm -rf src-$ver.tgz; false )
mkdir -p src
tar --strip-components=1 -xvf src-$ver.tgz -C src
cp -r --reflink=auto -t src meson*

export CC=${CC-musl-gcc}
meson build src \
	--wrap-mode forcefallback \
	--buildtype release \
	--strip \
    -Db_lto=true \
	-Ddefault_library=static \
	-Dstatic=true \
    -Drdkafka:WITH_ZSTD=enabled \
    -Drdkafka:WITH_ZLIB=enabled \
    -Drdkafka:WITH_LZ4_EXT=enabled \
	-Drdkafka:WITH_SSL=enabled \
    -Drdkafka:WITH_CURL=disabled \
	-Drdkafka:WITH_SASL=disabled
sed -ri s#linux/mman.h#sys/mman.h# src/meson/openssl-*/crypto/mem_sec.c
ninja -Cbuild kcat

test "$(meson introspect --projectinfo build | jq -r .version)" == $ver || ( echo 1>&2 "Version Weirdness"; false )
LC_ALL=C ldd build/kcat |& grep -qi 'not.*dynamic' || ( echo 1>&2 "Not a static executable"; ldd build/kcat; false )

cat >build/kcat-LICENSES.txt \
	src/meson/librdkafka-*/LICENSES.txt \
	<(echo -e '\nyajl.LICENSE\n------------\n') \
	src/meson/yajl-2.1.0/COPYING
