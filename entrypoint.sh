#!/bin/sh

DERP_CERT_DIR="/certs"

CMD="derper -hostname $DERP_DOMAIN -a :$DERP_HTTPS_PORT  -stun-port $DERP_STUN_PORT -certdir $DERP_CERT_DIR "

check_manual_certs() {
    # 检查 $DERP_CERT_DIR/$DERP_DOMAIN.crt 和 $DERP_CERT_DIR/$DERP_DOMAIN.key 是否存在
    if [ ! -f "$DERP_CERT_DIR/$DERP_DOMAIN.crt" ] || [ ! -f "$DERP_CERT_DIR/$DERP_DOMAIN.key" ]; then
        echo "Missing cert or key file for $DERP_DOMAIN"
        exit 1
    fi
}

# 检查 $DERP_ENABLE_ACME 是否为 true, 如果是, 则执行 check_manual_certs, 无误后添加 "-certmode manual -http-port -1" 参数, 如果不为 true, 则添加 "-certmode letsencrypt -http-port $DERP_HTTP_PORT"
if [ "$DERP_ENABLE_ACME" = "true" ]; then
    check_manual_certs
    CMD="$CMD -certmode manual -http-port -1"
else
    # 检查 $DERP_HTTP_PORT 是否为 0 或负数
    if [ "$DERP_HTTP_PORT" -le 0 ]; then
        echo "DERP_HTTP_PORT must be greater than 0"
        exit 1
    fi
    CMD="$CMD -certmode letsencrypt -http-port $DERP_HTTP_PORT"
fi

# 如果 DERP_ENABLE_VERIFY_CLIENTS 为 true, 则为 CMD 追加 -verify-clients 参数
if [ "$DERP_ENABLE_VERIFY_CLIENTS" = "true" ]; then
    CMD="$CMD -verify-clients"
fi

# 执行 CMD
$CMD
