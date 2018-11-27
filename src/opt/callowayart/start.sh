#!/bin/bash
set -euo pipefail

chmod -R ugo+rwx /var/www/html/wp-content
docker-entrypoint.sh $@
