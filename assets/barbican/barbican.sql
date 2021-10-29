create database barbican;
grant all privileges on barbican.* to barbican@'localhost' identified by 'ADMPWD';
grant all privileges on barbican.* to barbican@'%' identified by 'ADMPWD';
flush privileges;