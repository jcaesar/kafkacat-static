#!/usr/bin/env bash

set -eu

ver=$(sed -rn "H;1h;\$!d;x;s/^.*project\([^)]*kafkacat[^)]*version:[ \t]*'([^']+)'.*$/\1/p" meson.build)
wget https://github.com/edenhill/kafkacat/archive/$ver.tar.gz -Osrc.tgz
tar --strip-components=1 -xvf src.tgz
rm src.tgz

CC=musl-gcc meson build --wrap-mode forcefallback \
	-Ddefault_library=static \
	-Dstatic=true \
	-Drdkafka:WITH_SSL=disabled \
	-Drdkafka:WITH_SASL=disabled
ninja -Cbuild kafkacat

test "$(meson introspect --projectinfo build | jq -r .version)" == $ver || ( echo 1>&2 "Version Weirdness"; false )
ldd build/kafkacat | grep -qi 'not.*dynamic' || ( echo 1>&2 "Not a static executable"; ldd build/kafkacat; false )

cat >kafkacat-LICENSES.txt \
	meson/librdkafka-1.0.1/LICENSES.txt \
	<(echo -e '\nyajl.LICENSE\n------------\n') \
	meson/yajl-2.1.0/COPYING
