#!/bin/sh
db_root_password=
db_password=
db_username=
db_name=
install_database (db_root_password, db_password, db_username, db_name) {
  mysql -u $db_username -p$db_password $db_name < create.sql
  mysql -u $db_username -p$db_password $db_name < schema.sql
  mysql -u $db_username -p$db_password $db_name < procedures.sql
}
seed_database (db_password, db_username, db_name) {
  for i in `seq 1..254`; do
    for j in `seq 1..254`; do
      mysql -u $db_username -p$db_password $db_name -e "INSERT INTO ip_address_pool (name) VALUES (\"192.168.$i.$j\")";
    done
  done
  for i in vlan_tag_pool vswitch_port_pool access_port_pool; do
    end=65535;
    [ $i = 'vlan_tag_pool' ] && start=0
    [ $i = 'vswitch_port_pool' ] && start=0
    [ $i = 'access_port_pool' ] && start=6000
    echo "$i $start $end";
    for j in `seq $start $end`; do
      mysql -u $db_username -p$db_password $db_name -e "INSERT INTO $i (name) VALUES (\"$j\")";
    done
  done
}
install_database $db_root_password $db_password $db_username $db_name
seed_database $db_password
