#requires: plugin vagrant-reload
BOX_IMAGE = "peru/ubuntu-20.04-server-amd64"
REPO_IP = "192.168.122.100"
REPO_PORT = "8081"
INFRA_GW = "130.220.13.1"
INFRA_MASK = "24"
INFRA_DNS = "130.220.13.10"
INFRA_DHCP_START = "130.220.13.200"
INFRA_DHCP_END = "130.220.13.254"
INFRA_NTP = "ptbtime1.ptb.de"
CTRL_HOST_IP = "130.220.13.30"
CTRL_VMS_NET_IP = "192.168.123.1"
CTRL_VMS_NET_MASK = "255.255.255.0"
CTRL_REPO_NET_IP = "192.168.122.200"
COMP_HOST_IP = "130.220.13.51"
COMP_REPO_NET_IP = "192.168.122.201"
STOR_HOST_IP = "130.220.13.50"
STOR_REPO_NET_IP = "192.168.122.202"

#to be able to deploy glance to any node
GLANCE_IP = CTRL_HOST_IP

Vagrant.configure("2") do |config|
    
    #Disabling the default /vagrant share
    config.vm.synced_folder ".", "/vagrant", disabled: true
    
    #Provide assets to every instance
    config.vm.provision "file", source: "assets" , destination: "/tmp/assets"
    config.vm.provision :shell, :path => "assets/provision_base.sh" , :args => [REPO_IP, REPO_PORT]
    
    config.vm.define "control-node" do |subconfig|
        subconfig.vm.hostname = "control-node"
        subconfig.vm.box = BOX_IMAGE
        subconfig.vm.network :private_network, ip: CTRL_HOST_IP
        subconfig.vm.network :private_network,
            :libvirt__network_name => 'Instances Network',
            :libvirt__dhcp_enabled => false,
            :libvirt__forward_mode => 'nat',
            :libvirt__host_ip => CTRL_VMS_NET_IP,
            :libvirt__netmask => CTRL_VMS_NET_MASK
        subconfig.vm.network :private_network, ip: CTRL_REPO_NET_IP
        subconfig.vm.provider "libvirt" do |libvirt|
            libvirt.driver = "kvm"
            libvirt.memory = "16384"
            libvirt.cpus = 4
        end

        subconfig.vm.provision :reload
        subconfig.vm.provision "file", source: "assets" , destination: "/tmp/assets"
        subconfig.vm.provision :shell, :path => "assets/provision_control-node.sh" , :args => [CTRL_HOST_IP, INFRA_GW, INFRA_MASK, INFRA_DNS, INFRA_DHCP_START, INFRA_DHCP_END, INFRA_NTP, GLANCE_IP]
    end

    config.vm.define "compute-node" do |subconfig|
        subconfig.vm.hostname = "compute-node"
        subconfig.vm.box = BOX_IMAGE
        subconfig.vm.network :private_network, ip: COMP_HOST_IP
        subconfig.vm.network :private_network, ip: COMP_REPO_NET_IP
        subconfig.vm.provider "libvirt" do |libvirt|
            libvirt.driver = "kvm"
            libvirt.memory = "8096"
            libvirt.cpus = 8
        end

        subconfig.vm.provision :reload
        subconfig.vm.provision "file", source: "assets" , destination: "/tmp/assets"
        subconfig.vm.provision :shell, :path => "assets/provision_compute-node.sh" , :args => [COMP_HOST_IP, CTRL_HOST_IP, INFRA_NTP]
    end

    config.vm.define "storage-node" do |subconfig|
        subconfig.vm.hostname = "storage-node"
        subconfig.vm.box = BOX_IMAGE
        subconfig.vm.network :private_network, ip: STOR_HOST_IP
        subconfig.vm.network :private_network, ip: STOR_REPO_NET_IP
        subconfig.vm.provider "libvirt" do |libvirt|
            libvirt.driver = "kvm"
            libvirt.memory = "8096"
            libvirt.cpus = 4
            (1..4).each do |i|
                libvirt.storage :file, :size => '20G', :format => 'qcow2'
            end
        end

        subconfig.vm.provision :reload
        subconfig.vm.provision "file", source: "assets" , destination: "/tmp/assets"
        subconfig.vm.provision :shell, :path => "assets/provision_storage-node.sh" , :args => [STOR_HOST_IP, CTRL_HOST_IP, INFRA_NTP, GLANCE_IP]
    end
end