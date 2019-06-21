FROM gentoo/portage:latest as portage
FROM liftm/gentoo-uclibc as builder
COPY --from=portage /usr/portage /usr/portage

RUN true \
	&& echo 'CONFIG_PROTECT="-*"' >>/etc/portage/make.conf \
	&& echo 'USE="static static-libs"' >>/etc/portage/make.conf \
	&& echo 'FEATURES="-sandbox -ipc-sandbox -network-sandbox -pid-sandbox -usersandbox"' >>/etc/portage/make.conf # can't sandbox in the sandbox \
	&& sed -i '/^\/usr\/lib$/ d; /^\/lib$/ d;' /etc/ld.so.conf

RUN emerge --unmerge openssh ssh \
	&& emerge --autounmask-write --autounmask-continue --tree --verbose --update --deep --newuse \
		--exclude='openssh ssh' \
		--exclude='gzip bzip2 tar xz' \
		--exclude='debianutils patch pinentry' \
		kafkacat meson dev-util/ninja \
		app-arch/zstd app-arch/lz4 dev-libs/cyrus-sasl

WORKDIR /opt/kafkacat
RUN tar --strip-components=1 -xvf /usr/portage/distfiles/*kafkacat*
		
COPY . .
RUN true \
	&& meson build --wrap-mode forcefallback -Ddefault_library=static -Dstatic=true \
	&& ninja -C build kafkacat \
	&& ldd build/kafkacat | grep -q 'not.*dynamic'

FROM scratch
USER 1000
ENTRYPOINT ["/kafkacat"]
COPY --from=builder /opt/kafkacat/build/kafkacat /
