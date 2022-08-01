FROM alpine:latest as openssl
ENV VERSION_OPENSSL=openssl-1.1.1k

WORKDIR /tmp/src
RUN apk add gcc make musl-dev autoconf automake linux-headers
RUN wget https://www.openssl.org/source/"${VERSION_OPENSSL}".tar.gz
RUN tar -xf "${VERSION_OPENSSL}".tar.gz
WORKDIR /tmp/src/"${VERSION_OPENSSL}"
RUN ./config \
        -Wl,-rpath=/opt/openssl/lib \
        --prefix=/opt/openssl \
        --openssldir=/opt/openssl \
        -DOPENSSL_NO_HEARTBEATS \
        no-weak-ssl-ciphers \
        no-ssl2 \
        no-ssl3 \
        --static -static \
        -fstack-protector-strong
RUN make depend && make -j`nprocs`
RUN make install_sw

FROM alpine:latest as compile
ENV VERSION_GETDNS=1.7.0
COPY --from=openssl /opt/openssl /opt/openssl

WORKDIR /tmp/src
RUN apk add gcc make unbound-dev musl-dev yaml-dev autoconf automake cmake
RUN wget https://getdnsapi.net/dist/getdns-"${VERSION_GETDNS}".tar.gz
RUN tar -xf getdns-"${VERSION_GETDNS}".tar.gz
WORKDIR /tmp/src/getdns-"${VERSION_GETDNS}"
RUN mkdir build
WORKDIR /tmp/src/getdns-"${VERSION_GETDNS}"/build

RUN cmake \
        -DBUILD_STUBBY=ON \
        -DENABLE_STUB_ONLY=ON \
        -DCMAKE_INSTALL_PREFIX=/opt/stubby \
        -DOPENSSL_INCLUDE_DIR=/opt/openssl/include \
        -DOPENSSL_CRYPTO_LIBRARY=/opt/openssl/lib/libcrypto.a \
        -DOPENSSL_SSL_LIBRARY=/opt/openssl/lib/libssl.a \
        -DUSE_LIBIDN2=OFF \
        -DBUILD_LIBEV=OFF \
        -DBUILD_LIBEVENT2=OFF \
        -DBUILD_LIBUV=OFF \
        -DBUILD_TESTING=OFF \
        -DBUILD_GETDNS_QUERY=OFF \
        -DBUILD_GETDNS_SERVER_MON=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_SHARED=OFF ..
RUN make -j`nprocs` && make install
RUN ldd /opt/stubby/bin/stubby
RUN strip /opt/stubby/bin/stubby
RUN rm -rf /opt/stubby/lib /opt/stubby/include /opt/stubby/share /opt/stubby/lib

FROM alpine:latest as build

RUN apk add yaml ca-certificates-bundle
RUN apk --purge del apk-tools

FROM scratch
COPY stubby.yml /opt/stubby/etc/stubby/stubby.yml
COPY --from=compile /opt/stubby /opt/stubby
COPY --from=build /etc/ssl/certs/ /etc/ssl/certs/
COPY --from=build /lib /lib
ENV PATH /opt/stubby/bin:$PATH
WORKDIR /opt/stubby
EXPOSE 8053/udp

CMD ["/opt/stubby/bin/stubby", "-C", "/opt/stubby/etc/stubby/stubby.yml"]
