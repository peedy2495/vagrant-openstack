# which node will host openstack controlling services
CTRL_HOST_IP="$NODE0_IP"

# which node will work as network-node
NET_HOST_IP="$NODE0_IP"

# where will the swift poxy be placed
SWIFT_PROXY="$NODE1_IP"

# to be able to deploy glance to any node
GLANCE_IP="$NODE2_IP"

# placement of DNS-Service
INFRA_DNS="$NODE0_IP"

# where barbican resides
CERT_IP="$NODE0_IP"

# placement of cinder-api 
CINDER_IP="$NODE0_IP"

# placement of manila-api
SHARE_IP="$NODE0_IP"

# placement of octavia-api
LOADBALANCER_IP="$NODE0_IP" 