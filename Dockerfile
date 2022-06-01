FROM debian:bullseye-slim as builder

ARG IMAGE_TAG

RUN apt-get update && apt-get install -y --no-install-recommends \
            git \
            build-essential \
            pkg-config \
            libusb-1.0-0-dev \
            libwxbase3.0-dev \
            libasound2-dev \
            debhelper \
            autotools-dev \
            ca-certificates \
            sed \
         && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/

RUN git clone --depth 1 https://github.com/sq7lrx/ircDDBGateway.git

WORKDIR /opt/ircDDBGateway

RUN git checkout Common/Version.h; \
    sed -i "s/const wxString VERSION = wxT(\"\([[:digit:]]\+\)/const wxString VERSION = wxT(\"$IMAGE_TAG (\1)/g" Common/Version.h

RUN make -j$(nproc) BUILD=release

FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
            libwxbase3.0-0v5 \
            wget \
            curl \
         && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Add the linbpq file
COPY --from=builder /opt/ircDDBGateway/ircDDBGateway/ircddbgatewayd /usr/bin/
COPY --from=builder /opt/ircDDBGateway/RemoteControl/remotecontrold /usr/bin/
COPY --from=builder /opt/ircDDBGateway/Data /usr/share/ircddbgateway/

ENTRYPOINT /usr/bin/ircddbgatewayd -confdir /etc/ircddbgateway -logdir /var/log/ircddbgateway -foreground -nolog

EXPOSE 30001/udp 30051-30059/udp 20001-20009/udp 30061-30065/udp 40000/udp 40001/tcp

LABEL org.opencontainers.image.authors="Adam SQ7LRX <sq7lrx@lavabs.com>" \
      org.opencontainers.image.url="https://github.com/sq7lrx/ircddbgateway-docker" \
      org.opencontainers.image.source="https://github.com/sq7lrx/ircddbgateway-docker" \
      org.opencontainers.image.title="ircDDBGateway" \
      org.opencontainers.image.description="Ham Radio D-STAR gateway based on the ircDDB network" \
      org.opencontainers.image.vendor="SQ7LRX"
