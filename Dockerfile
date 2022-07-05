FROM docker.io/library/debian:bullseye as builder

WORKDIR /opt/kafkacat
COPY ./deps.sh .
RUN ./deps.sh
COPY . .
RUN ./do.sh

RUN build/kcat -V && test $(build/kcat -h | wc -c) -gt 1000
RUN mkdir -p /opt/install/bin/ /opt/install/share/doc/ \
	&& cp build/kcat /opt/install/bin \
	&& cp build/kcat-LICENSES.txt /opt/install/share/doc/

FROM scratch
USER 1000
ENTRYPOINT ["/bin/kcat"]
COPY --from=builder /opt/install /
