# Stubby Docker Images

## What does this do?

Goal of this repo is to have a stubby image optimized to size, to be used easily in embedded devices, aka router. Right now size of this image is only 4.83 MB. I removed unbound as router's internal DNS server performs the caching duty.

For more info check out [MatthewVance repo](https://github.com/MatthewVance/stubby-docker).

~~ This allows you to run Stubby without losing the performance benefits of having a local caching DNS resolver. Historically, Stubby had better DNS over TLS support than Unbound. ~~

~~ To achieve this, this setup uses two containers, one running Stubby and another running Unbound. Unbound exposes DNS over port 53 and forwards requests not in its cache to the Stubby container on port 8053 (not publically exposed). Stubby then performs DNS resolution over TLS. ~~ By default, this is configured to use Cloudflare DNS. 

## How to use

### Building

```bash
cd stubby
podman build --format docker -t sarim/stubby:1.7.0 .
```

### Standard usage

Run these containers with the following command:

```bash
docker-compose up -d
```

Adjust ports and stubby.yml config file as needed.

Next, point your DNS to the IP of your Docker host running the Stubby container.

## Issues

If you have any problems with or questions about this image, please contact me through a [GitHub issue](https://github.com/sarim/stubby-docker/issues).

## Acknowledgments

These deserve credit for making this all possible.

- [Docker](https://www.docker.com/)
- [DNSCrypt server Docker image](https://github.com/jedisct1/dnscrypt-server-docker)
- [Docker](https://www.docker.com/)
- [Filippo Valsorda's Gist](https://gist.github.com/FiloSottile/2b171d359232114839358a74f7df33cb)
- [Franksn's Reddit post](https://www.reddit.com/r/pihole/comments/7oyh9m/guide_how_to_use_pihole_with_stubby/)
- [OpenSSL](http://www.libressl.org/)

## Licenses
### License

Unless otherwise specified, all code is released under the MIT License (MIT). See the [repository's `LICENSE` file](https://github.com/sarim/stubby-docker/blob/master/LICENSE) for details.

### Licenses for other components

- DNSCrypt server Docker image: [ISC License](https://github.com/jedisct1/dnscrypt-server-docker/blob/master/LICENSE)
- Docker: [Apache 2.0](https://github.com/docker/docker/blob/master/LICENSE)
- OpenSSL: [Apache-style license](https://www.openssl.org/source/license.html)
- Stubby: [BSD-3-Clause](https://github.com/getdnsapi/getdns/blob/develop/LICENSE) 
- Unbound: [BSD License](https://unbound.nlnetlabs.nl/svn/trunk/LICENSE)
