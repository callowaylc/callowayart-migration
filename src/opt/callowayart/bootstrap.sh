#!/usr/bin/env bash

alias database="mysql -hdb -uwordpress -pwordpress"
database -e"
  DROP DATABASE IF EXISTS wordpress
  DROP DATABASE IF EXISTS callowayart

  CREATE DATABASE wordpress
  CREATE DATABASE callowayart
"

#database -Dwordpress < ./migration.sql
#database -Dcallowayart < ./callowayart.sql

database -e"show databases"