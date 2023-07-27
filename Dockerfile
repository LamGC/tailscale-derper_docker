FROM golang:alpine AS production

# DERP 服务器的域名.
ENV DERP_DOMAIN=derp.localhost
# DERP 服务器的端口.
ENV DERP_HTTPS_PORT=8443
ENV DERP_HTTP_PORT=8080
ENV DERP_STUN_PORT=3478
ENV DERP_ENABLE_ACME=true

ENV PATH=$PATH:/root/go/bin

# 是否启用客户端验证功能.
ENV DERP_ENABLE_VERIFY_CLIENT=false

WORKDIR /root/

COPY --chown=root:root ./entrypoint.sh /root/entrypoint.sh

RUN go install tailscale.com/cmd/derper@main

ENTRYPOINT [ "/root/entrypoint.sh" ]
