FROM alpine:latest as compile
ENV VERSION_GETDNS=1.7.0

WORKDIR /tmp/src
RUN apk add gcc make unbound-dev musl-dev openssl-dev yaml-dev autoconf automake cmake patch
RUN wget https://getdnsapi.net/dist/getdns-"${VERSION_GETDNS}".tar.gz
RUN tar -xf getdns-"${VERSION_GETDNS}".tar.gz
ADD https://github.com/getdnsapi/stubby/commit/34ca1af2e13771e917c31c2e545f33810489ea21.diff /tmp/34ca1af2e13771e917c31c2e545f33810489ea21.diff
WORKDIR /tmp/src/getdns-"${VERSION_GETDNS}"/stubby
RUN patch -p1 < /tmp/34ca1af2e13771e917c31c2e545f33810489ea21.diff
WORKDIR /tmp/src/getdns-"${VERSION_GETDNS}"
RUN mkdir build
WORKDIR /tmp/src/getdns-"${VERSION_GETDNS}"/build

RUN cmake \
        -DBUILD_STUBBY=ON \
        -DENABLE_STUB_ONLY=ON \
        -DCMAKE_INSTALL_PREFIX=/opt/stubby \
        -DUSE_LIBIDN2=OFF \
        -DBUILD_LIBEV=OFF \
        -DBUILD_LIBEVENT2=OFF \
        -DBUILD_LIBUV=OFF \
        -DBUILD_TESTING=OFF \
        -DBUILD_GETDNS_QUERY=OFF \
        -DBUILD_GETDNS_SERVER_MON=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_SHARED=OFF ..
RUN make -j`nproc` && make install
RUN ldd /opt/stubby/bin/stubby
RUN strip /opt/stubby/bin/stubby
RUN rm -rf /opt/stubby/include /opt/stubby/share /opt/stubby/lib

FROM alpine:latest as build

RUN apk add yaml libssl1.1 libcrypto1.1 yaml tini
RUN apk --purge del apk-tools

FROM scratch
COPY stubby.yml /etc/opt/stubby/stubby/stubby.yml
COPY --from=compile /opt/stubby /opt/stubby
COPY --from=build /etc/ssl/ /etc/ssl/
COPY --from=build /lib /lib
COPY --from=build /sbin/tini /tini
ADD https://curl.se/ca/cacert.pem /cacert.pem
ENV PATH /opt/stubby/bin:$PATH
WORKDIR /opt/stubby
EXPOSE 8053/udp
ENTRYPOINT ["/tini", "--"]
CMD ["/opt/stubby/bin/stubby"]
