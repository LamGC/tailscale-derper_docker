#!/bin/sh

DERP_CERT_DIR="/certs"

CMD="derper -hostname $DERP_DOMAIN -stun-port $DERP_STUN_PORT -certdir $DERP_CERT_DIR"

check_manual_certs() {
    if [ ! -f "$DERP_CERT_DIR/$DERP_DOMAIN.crt" ] || [ ! -f "$DERP_CERT_DIR/$DERP_DOMAIN.key" ]; then
        echo "Missing cert or key file for $DERP_DOMAIN"
        exit 1
    fi
}

if [ "$DERP_ENABLE_ACME" = "false" ]; then
    check_manual_certs
    CMD="$CMD -certmode manual -http-port -1 -a :$DERP_HTTPS_PORT"
else
    if [ "$DERP_HTTP_PORT" -le 0 ]; then
        echo "DERP_HTTP_PORT must be greater than 0"
        exit 1
    fi
    CMD="$CMD -certmode letsencrypt -http-port $DERP_HTTP_PORT -a :443"
fi

if [ "$DERP_ENABLE_VERIFY_CLIENTS" = "true" ]; then
    CMD="$CMD -verify-clients"
fi

echo "Derper Command: $CMD"

$CMD
