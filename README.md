# tailscale-derper_docker

Tailscale DERP server on Docker.

English | [中文](README.zh.md)

## Supported tags

As Tailscale has not released a version for Derper, our repository will regularly build new images for Derper.

### Shared Tags

- Weekly updates：`main`，`latest`

### Simple Tags

- Fixed version number：`<yyyyMMdd>.<build-number>`

> In the future, it will support the release of Tailscale versions and the construction of corresponding images.

## Usage

### Quickstart

By using Derper's built-in Let's Encrypt ACME function, you can quickly start a Derper server.  

Firstly, ensure that the domain name has been resolved to the server IP, and then use the following command to start the container:

```bash
docker run -d --name derper --restart=always \
    -p 443:443 -p 80:80 \
    -p 3478:3478/udp \
    -e DERP_DOMAIN=<Domain> \
    -v derper_certs:/certs \
    lamgc/tailscale-derper
```

After starting the container, Derper will automatically request a certificate through HTTP and start the service.

> Note: If ACME automatic certificate issuance is enabled, the HTTPS port in the container will be forcibly set to `443`, and the HTTP port must be mapped to the host port `80` to allow ACME to verify domain ownership using HTTP-1.

### Custom Certificates

If you are not planning to use the automatic ACME feature, you can also map existing certificates to containers.  

Firstly, install the certificate into a folder (using `/root/ssl` as an example), name the certificate chain with `<Domain>.crt` (it is recommended to use fullchain pem file), and name the private key with `<Domain>.key`.

```
ssl
├── derper.example.org.crt
└── derper.example.org.key
```

Then use the following command to start the container:  

```bash
docker run -d --name derper --restart=always \ 
    -p 443:443 -p 80:80 \ 
    -p 3478:3478/udp \ 
    -e DERP_DOMAIN=<Domain> \ 
    -e DERP_ENABLE_ACME=false \ 
    -v /root/ssl:/certs \
    lamgc/tailscale-derper
```

### Enable Client Verify

If Derper needs to be set as a private node, it can be configured to enable client authentication functionality.  

Firstly, install the Tailscale client on the host and log in to your own Tailnet.  

Then, when creating the container, map `/var/run/tailscale/tailscaled.sock` to the container:

```bash
docker run -d --name derper --restart=always \
    -p 443:443 -p 80:80 \
    -p 3478:3478/udp \
    -e DERP_DOMAIN=<Domain> \
    -e DERP_ENABLE_VERIFY_CLIENTS=true \
    -v /var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock \
    lamgc/tailscale-derper
```

`-e DERP_ENABLE_VERIFY_CLIENTS=true` will instruct entrypoint.sh to add the xxx `-verify-clients` flag.

After enabling client authentication, Derper will access `/var/run/tailscale/tailscale.sock` to obtain connection information for other devices and verify incoming connections.
