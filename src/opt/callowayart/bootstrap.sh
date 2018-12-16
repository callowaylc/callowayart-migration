#!/usr/bin/env bash
set -x

while ! nc -z db 3306; do
  sleep 0.1 # wait for 1/10 of the second before check again
done

mysql -hdb -uroot -pwordpress -e"
  DROP DATABASE IF EXISTS wordpress;
  DROP DATABASE IF EXISTS callowayart;

  CREATE DATABASE wordpress;
  CREATE DATABASE callowayart;

  ALTER DATABASE wordpress CHARACTER SET utf8;
"

cat ./callowayart.sql | mysql -hdb -uroot -pwordpress -Dcallowayart
cat ./wordpress.sql | mysql -hdb -uroot -pwordpress -Dwordpress

# fix encoding issues
mysql -hdb -uroot -pwordpress -Dcallowayart -e"
  UPDATE wp_term_taxonomy SET description=CONVERT(CONVERT(description USING binary) USING utf8);
  UPDATE wp_posts SET post_content=CONVERT(CONVERT(post_content USING binary) USING utf8);

  ALTER DATABASE callowayart CHARACTER SET utf8 COLLATE utf8_bin;
  ALTER TABLE wp_term_taxonomy CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin;
"

mysql -hdb -uroot -pwordpress -Dwordpress -e"
  UPDATE wp_posts
    SET post_content = REPLACE(
      post_content, 'http://localhost/', '/'
    );
  UPDATE wp_posts
    SET post_content = REPLACE(
      post_content, 'http://dev.brandefined.net/wdp-103964-susan-calloway/', '/'
    );
"

cat <<EOF | mysql -hdb -uroot -pwordpress -Dwordpress
  INSERT INTO wp_users (
    ID, user_login, user_pass, user_nicename, user_email, user_status, display_name, user_registered
  ) VALUES (
    '1000', 'admin', MD5('admin!'), 'tempuser', 'fubar@fubar.com', '0', 'admin', NOW()
  );

  INSERT INTO wp_usermeta (
    umeta_id, user_id, meta_key, meta_value
  ) VALUES (
    NULL, '1000', 'wp_capabilities', 'a:1:{s:13:"administrator";b:1;}'
  );
  INSERT INTO wp_usermeta (
    umeta_id, user_id, meta_key, meta_value
  ) VALUES (
    NULL, '1000', 'wp_user_level', '10'
  );

  UPDATE wp_options SET
    option_value="https://${DOMAIN}"
  WHERE
    option_name="home" OR
    option_name="siteurl"
EOF

# install wordpress plugins
wp plugin install custom-permalinks \
  --version=1.4.0 \
  --activate \
  --allow-root

# perform actual migration
rake -T
rake replace_domain[migrated.callowayart.com]
rake migrate

# modify "sorting-order-by-start" field homepage grid
cat <<EOF | mysql -hdb -uroot -pwordpress -Dwordpress
  UPDATE wp_eg_grids SET
    params = REPLACE(
      params,
      '"sorting-order-by-start":"date"',
      '"sorting-order-by-start":"rand"'
    )
  WHERE
    id = 1
EOF
