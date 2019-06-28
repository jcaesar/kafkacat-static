# Kafkacat Statically Linked Executable

x64 only, no SSL/SASL. If that's easy to add, PRs please.

Can be downloaded and used directly, or…

## Used through docker
```bash
docker rum --rm -i liftm/kafkacat -b gregor:9092 -L
```

## Installed in some other docker image

```Dockerfile
FROM liftm/kafkacat:1.4.0 as kafkacat
FROM alpine
COPY --from=kafkacat / /usr
RUN $stuff
```

## You got a loicense for that?
```bash
# One way
docker save liftm/kafkacat | tar xfO - manifest.json | jq -r '.[]|.Layers|.[]' | while read l; do docker save liftm/kafkacat | tar xfO - $l | tar xfO - share/doc/kafkacat-LICENSES.txt; done
# Or another
docker create --name liftm-kafkacat-license liftm/kafkacat; docker export liftm-kafkacat-license | tar xfO - share/doc/kafkacat-LICENSES.txt; docker rm liftm-kafkacat-license >/dev/null
```
