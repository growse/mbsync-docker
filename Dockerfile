FROM debian:bookworm-20250721-slim AS builder

RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    DEBIAN_FRONTEND=noninteractive\
    apt-get update && \
    apt-get install --no-install-recommends -y build-essential git libssl-dev libsasl2-dev libtimedate-perl automake autoconf ca-certificates
WORKDIR /root

# renovate: datasource=git-tags depName=https://git.code.sf.net/p/isync/isync
ENV ISYNC_VERSION=v1.5.1
RUN git clone --depth 1 --branch ${ISYNC_VERSION} https://git.code.sf.net/p/isync/isync
WORKDIR /root/isync
RUN ./version.sh && ./autogen.sh && ./configure && make && make install

FROM python:3.13.5-slim-bookworm
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
    DEBIAN_FRONTEND=noninteractive\
    apt-get update && \
    apt-get install --no-install-recommends -y ca-certificates libsasl2-2 libsasl2-modules-kdexoauth2 libssl3
COPY --from=builder /usr/local/bin/mbsync /usr/local/bin/mbsync
COPY oauth2.py /usr/local/bin/oauth2.py
ENTRYPOINT ["/usr/local/bin/mbsync"]
