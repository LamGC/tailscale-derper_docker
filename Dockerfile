FROM golang:alpine AS build

USER root
WORKDIR /root/
ENV GOPATH=/root/go
RUN go install tailscale.com/cmd/derper@main

FROM alpine AS production

# DERP 服务器的域名.
ENV DERP_DOMAIN=derp.localhost
# DERP 服务器的端口.
ENV DERP_HTTPS_PORT=443
ENV DERP_HTTP_PORT=80
ENV DERP_STUN_PORT=3478
ENV DERP_ENABLE_ACME=true

ENV PATH=$PATH:/root/go/bin

# 是否启用客户端验证功能.
ENV DERP_ENABLE_VERIFY_CLIENT=false

WORKDIR /root/
VOLUME ["/var/lib/derper/"]
VOLUME ["/certs"]

COPY --chown=root:root ./entrypoint.sh /root/entrypoint.sh
COPY --from=build /root/go/bin /root/go/bin

ENTRYPOINT [ "/root/entrypoint.sh" ]
