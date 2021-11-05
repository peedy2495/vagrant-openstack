# enable OpenStack:Xena repositories
apt install -y software-properties-common
add-apt-repository -y cloud-archive:xena
apt update
apt upgrade -y

# prepare some basics
#sed -i "\@#NTP@cNTP=$INFRA_NTP" /etc/systemd/timesyncd.conf
KeySet NTP "$INFRA_NTP" /etc/systemd/timesyncd.conf
systemctl restart systemd-timesyncd.service