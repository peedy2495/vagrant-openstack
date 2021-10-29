create database heat;
grant all privileges on heat.* to heat@'localhost' identified by 'ADMPWD';
grant all privileges on heat.* to heat@'%' identified by 'ADMPWD';
flush privileges;