#!/usr/bin/env bash

while ! nc -z db 3306; do
  sleep 0.1 # wait for 1/10 of the second before check again
done

mysql -hdb -uroot -pwordpress -e"
  DROP DATABASE IF EXISTS wordpress;
  DROP DATABASE IF EXISTS callowayart;

  CREATE DATABASE wordpress;
  CREATE DATABASE callowayart;
"

mysql -hdb -uroot -pwordpress -Dcallowayart < ./callowayart.sql
mysql -hdb -uroot -pwordpress -Dwordpress < ./wordpress.sql

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

rake -T
rake replace_domain[migrated.callowayart.com]
rake migrate
