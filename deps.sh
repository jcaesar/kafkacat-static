#!/usr/bin/env bash

set -eu
apt update
apt install -y \
	jq \
	build-essential pkg-config \
	meson ninja-build \
	wget ca-certificates \
	musl-tools \
	git \
	python3-setuptools \
	zip
