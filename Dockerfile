FROM debian:bookworm-slim AS builder
RUN apt-get update && apt-get install -y build-essential git libssl-dev libsasl2-dev libtimedate-perl autoconf
WORKDIR /root
ENV ISYNC_VERSION=v1.4.4
RUN git clone --depth 1 --branch ${ISYNC_VERSION} https://git.code.sf.net/p/isync/isync
WORKDIR /root/isync
RUN ./autogen.sh && ./configure && make && make install

FROM python:slim-bookworm
RUN apt-get update && apt-get install -y ca-certificates libsasl2-2 libsasl2-modules-kdexoauth2 libssl3 && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/bin/mbsync /usr/local/bin/mbsync
COPY oauth2.py /usr/local/bin/oauth2.py
ENTRYPOINT /usr/local/bin/mbsync
