#!/bin/bash
set -e

/opt/akamai-ets/bin/ets-cli-config $@
PATH=/opt/akamai-ets/bin:$PATH
akamai-ets > /tmp/nodejs.log 2>&1