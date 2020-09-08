FROM debian:buster-slim AS builder
RUN apt-get update && apt-get install -y build-essential git libssl-dev libsasl2-dev libtimedate-perl autoconf
WORKDIR /root
RUN git clone --depth 1 --branch v1.3.3 https://git.code.sf.net/p/isync/isync
WORKDIR /root/isync
RUN ./autogen.sh
RUN ./configure
RUN make && make install

FROM debian:buster-slim
RUN apt-get update && apt-get install -y libsasl2-2 libsasl2-modules-kdexoauth2 libssl1.1
RUN rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/bin/mbsync /usr/local/bin/mbsync
ENTRYPOINT /usr/local/bin/mbsync