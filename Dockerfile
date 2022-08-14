FROM alpine:latest as compile
ENV VERSION_GETDNS=1.7.0

WORKDIR /tmp/src
RUN apk add gcc make unbound-dev musl-dev openssl-dev openssl-libs-static yaml-dev yaml-static autoconf automake cmake patch file tini-static git
RUN git clone --recurse-submodules --depth 1 --branch v"${VERSION_GETDNS}" https://github.com/getdnsapi/getdns.git getdns
ADD https://github.com/getdnsapi/stubby/commit/34ca1af2e13771e917c31c2e545f33810489ea21.diff /tmp/34ca1af2e13771e917c31c2e545f33810489ea21.diff
WORKDIR /tmp/src/getdns/stubby
RUN patch -p1 < /tmp/34ca1af2e13771e917c31c2e545f33810489ea21.diff
WORKDIR /tmp/src/getdns
RUN mkdir build
WORKDIR /tmp/src/getdns/build

RUN cmake \
        -DBUILD_STUBBY=ON \
        -DENABLE_STUB_ONLY=ON \
        -DCMAKE_INSTALL_PREFIX=/opt/stubby \
        -DOPENSSL_CRYPTO_LIBRARY=/usr/lib/libcrypto.a \
        -DOPENSSL_SSL_LIBRARY=/usr/lib/libssl.a \
        -DLIBYAML_LIBRARY=/usr/lib/libyaml.a \
        -DUSE_LIBIDN2=OFF \
        -DBUILD_LIBEV=OFF \
        -DBUILD_LIBEVENT2=OFF \
        -DBUILD_LIBUV=OFF \
        -DBUILD_TESTING=OFF \
        -DBUILD_GETDNS_QUERY=OFF \
        -DBUILD_GETDNS_SERVER_MON=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_SHARED=OFF \
        -DCMAKE_EXE_LINKER_FLAGS="-s -static" \
        ..
RUN make -j`nproc` && make install
RUN ls -lsh /opt/stubby/bin/stubby && file /opt/stubby/bin/stubby

FROM scratch
COPY stubby.yml /etc/opt/stubby/stubby/stubby.yml
COPY --from=compile /opt/stubby/bin/stubby /opt/stubby/bin/stubby
COPY --from=compile /sbin/tini-static /tini
ADD https://curl.se/ca/cacert.pem /cacert.pem
ENV PATH /opt/stubby/bin:$PATH
WORKDIR /opt/stubby
EXPOSE 8053/udp
ENTRYPOINT ["/tini", "--"]
CMD ["/opt/stubby/bin/stubby"]
