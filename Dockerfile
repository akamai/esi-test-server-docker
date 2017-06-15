# build using make
FROM ubuntu:trusty

ENV ETS_DIR=/opt/akamai-ets \
    NODE_DIR=/usr/src/app/

LABEL vendor="Akamai Technologies, Inc."

COPY akamai-ets_*.tar.gz run.sh /tmp/
COPY code-samples /tmp/esi-examples

RUN mkdir -p /tmp/akamai-ets && \
    tar -zxf /tmp/akamai-ets_*.tar.gz -C /tmp/akamai-ets --strip-components=1 && \
    cp -R /tmp/esi-examples /tmp/akamai-ets/files/bindist/virtual/localhost/docs/ && \
    cd /tmp && \
    tar -zcvf /tmp/akamai-ets/files/bindist/virtual/localhost/docs/esi-examples/esi-examples.tar.gz esi-examples > /dev/null 2>&1 && \
    cd /tmp/akamai-ets && \
    ./install.sh --headless && \
    rm -rf /tmp/akamai-ets && \
    rm -rf /tmp/esi-examples && \
    rm -f /tmp/akamai-ets_*.tar.gz && \
    cd /tmp && apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - && \
    apt-get install -y build-essential g++ python nodejs git && \
#install playground, using code from https://github.com/newscorpaus/akamai-ets/Dockerfile
    git clone https://github.com/newscorpaus/akamai-ets.git && \
    cd akamai-ets; git checkout 4d3cf03 && \
    mkdir -p ${ETS_DIR}/conf/ets/macros/ && cp files/conf/ets/macros/Playground.macro ${ETS_DIR}/conf/ets/macros/ && \
    cp files/conf/ets/vh_playground.conf ${ETS_DIR}/conf/ets/ && \
    mkdir -p ${NODE_DIR} && \
    cp -R ./ ${NODE_DIR} && \
    rm -rf /var/lib/apt/lists/*

WORKDIR ${NODE_DIR}
COPY playground/ ${ETS_DIR}/conf/

#build playground.min.js, and copy it to /home/playground
RUN  unset NODE_ENV && npm cache clean && npm install && \
    npm run build && rm -rf node_modules && \
    cp -R public/* /home/ && \
    npm install && npm link && \
    apt-get remove -y git python g++ build-essential && apt-get autoremove -y

# end install playground

EXPOSE 80

# no default arguments, but this will allow to pass arguments from "docker run ... ARGS" to "/tmp/run.sh ARGS", otherwise "/bin/bash ARGS" will be called
# more at https://docs.docker.com/engine/reference/builder/#understand-how-cmd-and-entrypoint-interact
CMD [""]

ENTRYPOINT ["/tmp/run.sh"]
