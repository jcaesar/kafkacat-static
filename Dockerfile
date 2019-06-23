FROM debian:buster as builder

RUN apt update \
	&& apt install -y \
		jq \
		build-essential pkg-config \
		libssl-dev libsasl2-dev \
		meson ninja-build \
		wget ca-certificates \
		musl-tools

WORKDIR /opt/kafkacat
COPY . .
RUN true \
	&& ver=$(sed -rn "H;1h;\$!d;x;s/^.*project\([^)]*kafkacat[^)]*version:[ \t]*'([^']+)'.*$/\1/p" meson.build) \
	&& wget https://github.com/edenhill/kafkacat/archive/$ver.tar.gz -O/opt/src.tgz \
	&& tar --strip-components=1 -xvf /opt/src.tgz \
	&& CC=musl-gcc meson build --wrap-mode forcefallback \
		-Ddefault_library=static -Dstatic=true -Drdkafka:WITH_SSL=disabled -Drdkafka:WITH_SASL=disabled \
	&& /usr/bin/test "$(meson introspect --projectinfo build | jq -r .version)" == $ver \
	&& ninja -Cbuild kafkacat \
	&& ldd build/kafkacat | grep -q 'not.*dynamic'

FROM scratch
USER 1000
ENTRYPOINT ["/kafkacat"]
COPY --from=builder /opt/kafkacat/build/kafkacat /
