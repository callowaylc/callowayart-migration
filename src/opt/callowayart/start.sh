#!/bin/bash
set -euo pipefail

chmod -R ugo+rwx /var/www/html/wp-content
a2enmod  headers

docker-entrypoint.sh "apache2-foreground"
