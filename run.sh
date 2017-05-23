#!/bin/bash

if [[ -z "${CONFIGURE_OPTS}" ]]; then
    export CONFIGURE_OPTS="$CONFIGURE_DEFAULTS $CONFIGURE_EXTRA_OPTS"
fi
/opt/akamai-ets/bin/ets-cli-config $CONFIGURE_OPTS
/opt/akamai-ets/bin/apachectl -D FOREGROUND