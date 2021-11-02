create database manila;
grant all privileges on manila.* to manila@'localhost' identified by 'ADMPWD';
grant all privileges on manila.* to manila@'%' identified by 'ADMPWD';
flush privileges;