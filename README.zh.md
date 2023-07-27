# tailscale-derper_docker

使用 Docker 部署 Tailscale Derper。

[English](README.md) | 中文

## 支持的镜像标签

由于 Tailscale 并没有为 Derper 发布版本，因此本仓库将定期为 Derper 构建新的镜像。

### 共享的标签

- 每周更新：`main`，`latest`

### 固定的标签

- 固定版本：`<yyyyMMdd>.<build-number>`

> 后续会支持根据 Tailscale 的版本发布，构建对应版本的 Derper 镜像。

## Usage

### Quickstart

通过 Derper 自带的 Let's Encrypt ACME 功能，可以快速启动一个 Derper 服务器。  

首先，确保域名已经解析到服务器 IP 上，然后使用如下命令启动容器：

```bash
docker run -d --name derper --restart=always \
    -p 443:443 -p 80:80 \
    -p 3478:3478/udp \
    -e DERP_DOMAIN=<Domain> \
    -v derper_certs:/certs \
    lamgc/tailscale-derper
```

启动容器后，Derper 将自动通过 HTTP 方式申请证书并启动服务。

> 注意：如果启用 ACME 自动签发证书，那么容器中的 HTTPS 端口将会强制设定为 `443`，HTTP 端口请务必映射为宿主机 `80`` 端口，以允许 Derper 使用 HTTP-1 方式验证域名所有权。

### Custom Certificates

如果你不打算使用自动 ACME 功能，也可以将已有的证书映射到容器中。 

首先将证书安装到一个文件夹中（这里以 `/root/ssl` 为例），以 `<Domain>.crt` 命名证书链（建议使用 fullchain），以 `<Domain>.key` 命名私钥。  

就像这样（假设域名是 `derper.example.org`）：

```
ssl
├── derper.example.org.crt
└── derper.example.org.key
```

然后使用如下命令启动容器：
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

如果需要将 Derper 设为私有节点，可配置启用客户端验证功能。

首先在宿主机安装好 Tailscale 客户端，并登录到自己的 Tailnet。

然后在创建容器时将 `/var/run/tailscale/tailscaled.sock` 映射到容器中：

```bash
docker run -d --name derper --restart=always \
    -p 443:443 -p 80:80 \
    -p 3478:3478/udp \
    -e DERP_DOMAIN=<Domain> \
    -e DERP_ENABLE_VERIFY_CLIENTS=true \
    -v /var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock \
    lamgc/tailscale-derper
```

`-e DERP_ENABLE_VERIFY_CLIENTS=true` 将会指示 entrypoint.sh 添加 `-verify-clients`。  

derper 在启用客户端验证后，会访问 `/var/run/tailscale/tailscaled.sock` 获取其他设备的连接信息，并对传入连接进行验证。
