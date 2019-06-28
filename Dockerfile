FROM debian:buster as builder

WORKDIR /opt/kafkacat
COPY ./deps.sh .
RUN ./deps.sh
COPY . .
RUN ./do.sh

FROM scratch
USER 1000
ENTRYPOINT ["/kafkacat"]
COPY --from=builder /opt/kafkacat/build/kafkacat /
