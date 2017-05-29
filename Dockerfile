# build using make
FROM ubuntu:trusty

LABEL vendor="Akamai Technologies, Inc."

COPY akamai-ets_*.tar.gz /tmp
COPY run.sh /tmp

RUN mkdir -p /tmp/akamai-ets && \
    tar -zxf /tmp/akamai-ets_*.tar.gz -C /tmp/akamai-ets --strip-components=1 && \
    cd /tmp/akamai-ets && \
    ./install.sh --headless && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/akamai-ets && \
    rm -f /tmp/akamai-ets_*.tar.gz

EXPOSE 80
EXPOSE 81

ENV CONFIGURE_EXTRA_OPTS=""
ENV CONFIGURE_DEFAULTS="--ets_port=80 --local_hostname=localhost --sandbox_port=81"

ENTRYPOINT ["/tmp/run.sh"]
