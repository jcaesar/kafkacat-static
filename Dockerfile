FROM debian:buster as builder

RUN apt update \
	&& apt install -y \
		jq \
		build-essential pkg-config \
		meson ninja-build \
		wget ca-certificates \
		musl-tools

WORKDIR /opt/kafkacat
COPY . .
RUN ./do.sh

FROM scratch
USER 1000
ENTRYPOINT ["/kafkacat"]
COPY --from=builder /opt/kafkacat/build/kafkacat /
