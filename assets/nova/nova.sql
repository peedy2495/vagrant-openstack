CREATE DATABASE IF NOT EXISTS nova;
GRANT ALL PRIVILEGES ON nova.* TO nova@'localhost' IDENTIFIED BY 'ADMPWD';
GRANT ALL PRIVILEGES ON nova.* TO nova@'%' IDENTIFIED BY 'ADMPWD';
CREATE DATABASE IF NOT EXISTS nova_api;
GRANT ALL PRIVILEGES ON nova_api.* TO nova@'localhost' IDENTIFIED BY 'ADMPWD';
GRANT ALL PRIVILEGES ON nova_api.* TO nova@'%' IDENTIFIED BY 'ADMPWD';
CREATE DATABASE IF NOT EXISTS placement;
GRANT ALL PRIVILEGES ON placement.* TO placement@'localhost' IDENTIFIED BY 'ADMPWD';
GRANT ALL PRIVILEGES ON placement.* TO placement@'%' IDENTIFIED BY 'ADMPWD';
CREATE DATABASE IF NOT EXISTS nova_cell0;
GRANT ALL PRIVILEGES ON nova_cell0.* TO nova@'localhost' IDENTIFIED BY 'ADMPWD';
GRANT ALL PRIVILEGES ON nova_cell0.* TO nova@'%' IDENTIFIED BY 'ADMPWD';
FLUSH PRIVILEGES;