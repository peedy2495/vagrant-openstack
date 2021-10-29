openstack user create --domain default --project service --password $SERVPWD heat
openstack role add --project service --user heat admin

openstack role create heat_stack_owner
openstack role create heat_stack_user

openstack role add --project admin --user admin heat_stack_owner

openstack service create --name heat --description "Openstack Orchestration" orchestration
openstack service create --name heat-cfn --description "Openstack Orchestration" cloudformation

heat_api=$HOST_IP
openstack endpoint create --region RegionOne orchestration public http://$heat_api:8004/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne orchestration internal http://$heat_api:8004/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne orchestration admin http://$heat_api:8004/v1/%\(tenant_id\)s

openstack endpoint create --region RegionOne cloudformation public http://$heat_api:8000/v1
openstack endpoint create --region RegionOne cloudformation internal http://$heat_api:8000/v1
openstack endpoint create --region RegionOne cloudformation admin http://$heat_api:8000/v1

openstack domain create --description "Stack projects and users" heat
openstack user create --domain heat --password servicepassword heat_domain_admin
openstack role add --domain heat --user heat_domain_admin admin

ReplVar ADMPWD /tmp/assets/heat/heat.sql
mysql --user=root < /tmp/assets/heat/heat.sql

