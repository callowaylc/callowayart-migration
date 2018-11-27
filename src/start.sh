#!/bin/sh

mkdir -p /var/lib/varnish/`hostname` && chown nobody /var/lib/varnish/`hostname`
varnishd -s malloc,${VARNISH_MEMORY} -a :80 -f /etc/varnish/default.vcl
sleep 1
varnishlog