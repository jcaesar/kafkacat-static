FROM debian:buster as builder

WORKDIR /opt/kafkacat
COPY ./deps.sh .
RUN ./deps.sh
COPY . .
RUN ./do.sh

RUN mkdir -p /opt/install/bin/ /opt/install/share/doc/ \
	&& cp build/kafkacat /opt/install/bin \
	&& cp kafkacat-LICENSES.txt /opt/install/share/doc/

FROM scratch
USER 1000
ENTRYPOINT ["/bin/kafkacat"]
COPY --from=builder /opt/install /
