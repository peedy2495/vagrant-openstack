create database designate;
grant all privileges on designate.* to designate@'localhost' identified by 'ADMPWD';
grant all privileges on designate.* to designate@'%' identified by 'ADMPWD';
flush privileges;