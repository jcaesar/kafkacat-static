FROM debian:buster as builder

WORKDIR /opt/kafkacat
COPY ./deps.sh .
RUN ./deps.sh
COPY . .
RUN ./do.sh

# This will only work with a recent, non-released version of upx (afaik not easily available except for from my own repo), so I'll limit it to this dockerfile
COPY --from=liftm/upx / /usr
RUN upx -k --best --lzma build/kafkacat

RUN build/kafkacat -V && test $(build/kafkacat -h | wc -c) -gt 1000
RUN mkdir -p /opt/install/bin/ /opt/install/share/doc/ \
	&& cp build/kafkacat /opt/install/bin \
	&& cp kafkacat-LICENSES.txt /opt/install/share/doc/

FROM scratch
USER 1000
ENTRYPOINT ["/bin/kafkacat"]
COPY --from=builder /opt/install /
