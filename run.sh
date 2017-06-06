#!/bin/bash
set -e

/opt/akamai-ets/bin/ets-cli-config $@
/opt/akamai-ets/bin/apachectl -D FOREGROUND