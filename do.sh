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
	-Ddefault_library=static \
	-Dstatic=true \
	-Drdkafka:WITH_SSL=disabled \
	-Drdkafka:WITH_SASL=disabled
ninja -Cbuild kcat

test "$(meson introspect --projectinfo build | jq -r .version)" == $ver || ( echo 1>&2 "Version Weirdness"; false )
LC_ALL=C ldd build/kcat |& grep -qi 'not.*dynamic' || ( echo 1>&2 "Not a static executable"; ldd build/kcat; false )

cat >build/kcat-LICENSES.txt \
	src/meson/librdkafka-*/LICENSES.txt \
	<(echo -e '\nyajl.LICENSE\n------------\n') \
	src/meson/yajl-2.1.0/COPYING
