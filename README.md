# tailscale-derper_docker

Tailscale DERP server on Docker.

## Usage

### Quickstart

通过 Derper 自带的 Let's Encrypt ACME 功能，可以快速启动一个 Derper 服务器。
首先，确保域名已经解析到服务器 IP 上，然后使用如下命令启动容器：

```bash
docker run -d --name derper --restart=always \ 
    -p 443:8443 -p 80:8080 \ 
    -p 3478:3478/udp \ 
    -e DERP_DOMAIN=derper.example.com \ 
    lamgc/tailscale-derper
```

启动容器后，Derper 将自动通过 HTTP 方式申请证书并启动服务。

### Custom Certificates

如果你已经有了自己的证书，可以通过挂载卷的方式使用自己的证书。  
首先将证书安装到一个文件夹中（这里以 `/root/ssl` 为例），以 `<Domain>.crt` 命名证书链（建议使用 fullchain），以 `<Domain>.key` 命名私钥。  
然后使用如下命令启动容器：
```bash
docker run -d --name derper --restart=always \ 
    -p 443:8443 -p 80:8080 \ 
    -p 3478:3478/udp \ 
    -e DERP_DOMAIN=derper.example.com \ 
    -e DERP_ENABLE_ACME=false \ 
    -v /root/ssl:/certs \ 
    lamgc/tailscale-derper
```


