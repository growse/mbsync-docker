FROM debian:buster-slim AS builder
RUN apt-get update && apt-get install -y build-essential git libssl-dev libsasl2-dev libtimedate-perl autoconf
WORKDIR /root
RUN git clone --depth 1 --branch v1.4.0 https://git.code.sf.net/p/isync/isync
WORKDIR /root/isync
RUN ./autogen.sh
RUN ./configure
RUN make && make install

FROM python:slim
RUN apt-get update && apt-get install -y ca-certificates libsasl2-2 libsasl2-modules-kdexoauth2 libssl1.1
RUN rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/bin/mbsync /usr/local/bin/mbsync
COPY oauth2.py /usr/local/bin/oauth2.py
ENTRYPOINT /usr/local/bin/mbsync
