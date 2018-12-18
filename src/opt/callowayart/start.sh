#!/bin/bash
set -euo pipefail

chmod -R ugo+rwx /var/www/html/wp-content
a2enmod  headers

wp plugin install custom-permalinks \
  --version=1.4.0 \
  --activate \
  --allow-root

docker-entrypoint.sh "apache2-foreground"
