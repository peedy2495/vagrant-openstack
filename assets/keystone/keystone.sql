CREATE DATABASE IF NOT EXISTS keystone;
GRANT ALL PRIVILEGES ON keystone.* TO keystone@'localhost' IDENTIFIED BY 'ADMPWD';
GRANT ALL PRIVILEGES ON keystone.* TO keystone@'%' IDENTIFIED BY 'ADMPWD';
FLUSH PRIVILEGES;