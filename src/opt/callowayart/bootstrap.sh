#!/usr/bin/env bash

mysql -hdb -uroot -pwordpress -e"
  DROP DATABASE IF EXISTS wordpress;
  DROP DATABASE IF EXISTS callowayart;

  CREATE DATABASE wordpress;
  CREATE DATABASE callowayart;
"

mysql -hdb -uroot -pwordpress -Dcallowayart < ./callowayart.sql
mysql -hdb -uroot -pwordpress -Dwordpress < ./migration.sql

rake -T
rake migrate
