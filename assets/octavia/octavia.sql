create database octavia;
grant all privileges on octavia.* to octavia@'localhost' identified by 'ADMPWD';
grant all privileges on octavia.* to octavia@'%' identified by 'ADMPWD';
flush privileges;