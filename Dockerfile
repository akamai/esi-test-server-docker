# build using make
FROM ubuntu:trusty

ENV ETS_DIR     /opt/akamai-ets
ENV NODE_DIR    /usr/src/app/

LABEL vendor="Akamai Technologies, Inc."

COPY akamai-ets_*.tar.gz /tmp
COPY run.sh /tmp
COPY code-samples /tmp/esi-examples

RUN mkdir -p /tmp/akamai-ets && \
    tar -zxf /tmp/akamai-ets_*.tar.gz -C /tmp/akamai-ets --strip-components=1 && \
    cp -R /tmp/esi-examples /tmp/akamai-ets/files/bindist/virtual/localhost/docs/ && \
    cd /tmp && \
    tar -zcvf /tmp/akamai-ets/files/bindist/virtual/localhost/docs/esi-examples/esi-examples.tar.gz esi-examples > /dev/null 2>&1 && \
    cd /tmp/akamai-ets && \
    ./install.sh --headless && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/akamai-ets && \
    rm -rf /tmp/esi-examples && \
    rm -f /tmp/akamai-ets_*.tar.gz && \
    cd /tmp && apt-get update && apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - && \
    sudo apt-get install -y build-essential g++ python nodejs

#install playground, using code from https://github.com/newscorpaus/akamai-ets/Dockerfile

RUN mkdir -p ${NODE_DIR}
WORKDIR ${NODE_DIR}
COPY akamai-ets/ ${NODE_DIR}

#build playground.min.js, and copy it to /home/playground
RUN  unset NODE_ENV && npm cache clean && npm install && \
    npm run build && rm -rf node_modules && \
    cp -R public/* /home/

#install production modules
RUN  npm install && npm link

COPY playground/ ${ETS_DIR}/conf/
COPY akamai-ets/files/conf/ets/macros/Playground.macro ${ETS_DIR}/conf/ets/macros/Playground.macro
COPY akamai-ets/files/conf/ets/vh_playground.conf ${ETS_DIR}/conf/ets/

# end install playground

RUN apt-get remove -y python g++ build-essential && apt-get autoremove -y

EXPOSE 80
EXPOSE 81
EXPOSE 82

ENTRYPOINT ["/tmp/run.sh"]
