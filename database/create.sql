create database vmlab;
grant all privileges on $db_name.* to \'$db_username\'@localhost identified by \'$db_password\';
grant all privileges on $db_name.* to \'$db_username\'@'%' identified by \'$db_password\';
flush privileges;
