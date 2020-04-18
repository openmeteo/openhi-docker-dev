#!/bin/bash

set -ex

get_apt_proxy_line() {
    # Are we on Linux?
    if [ ! -f /proc/net/tcp ]; then
        # No - we can't use this functionality in this case
	echo ''
	return
    fi

    # Is port 3142 open on localhost?
    if grep -q ':0C46 ' /proc/net/tcp; then
        # Yes - then assume the docker host is an apt proxy
        echo 'Acquire::http::Proxy "http://172.17.0.1:3142";'
    else
        # No - assume we have no apt proxy
        echo ''
    fi
}

if [ ! -e enhydris/enhydris_project/settings/local.py ]; then
    cp local.py enhydris/enhydris_project/settings/
fi
docker build \
    -t enhydris-dev \
    --build-arg apt_proxy_line="`get_apt_proxy_line`" \
    .
