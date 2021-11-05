#requires: plugin vagrant-reload

#load variables used by host and guest
require_relative 'assets/global'

# generate ssh keys for passwordless vice versa guest accesses
puts `chmod +x assets/createSSHKeys.sh`
puts `assets/createSSHKeys.sh`

# get external dependencies
puts `chmod +x assets/gitrepos.sh`
puts `assets/gitrepos.sh`

Vagrant.configure("2") do |config|
    

    #Disabling the default /vagrant share
    config.vm.synced_folder ".", "/vagrant", disabled: true
    
    #Provide assets to every instance
    config.vm.provision "file", source: "assets" , destination: "/tmp/assets"
    config.vm.provision :shell, :path => "assets/provision_base.sh", :args => [ASSETS]
    
    config.vm.define "node0" do |subconfig|
        subconfig.vm.hostname = "node0"
        subconfig.vm.box = BOX_IMAGE
        subconfig.vm.network :private_network, ip: NODE0_IP
        subconfig.vm.network :private_network,
            :libvirt__network_name => 'Instances Network',
            :libvirt__dhcp_enabled => false,
            :libvirt__forward_mode => 'nat',
            :libvirt__host_ip => CTRL_VMS_NET_IP,
            :libvirt__netmask => CTRL_VMS_NET_MASK
        subconfig.vm.network :private_network, ip: NODE0_REPO_NET_IP
        subconfig.vm.provider "libvirt" do |libvirt|
            libvirt.driver = "kvm"
            libvirt.memory = "16384"
            libvirt.cpus = 4
            libvirt.storage_pool_name = "machines"
            # storages for cinder (vdb-vde)
            (1..4).each do |i|
                libvirt.storage :file, :size => '10G', :format => 'qcow2'
            end
            # storages for swift (vdf-vdi)
            (1..4).each do |i|
                libvirt.storage :file, :size => '20G', :format => 'qcow2'
            end
            # storage for glance (vdj)
            libvirt.storage :file, :size => '30G', :format => 'qcow2'
        end

        subconfig.vm.provision :reload
        subconfig.vm.provision "file", source: "assets" , destination: "/tmp/assets"
        subconfig.vm.provision :shell, :path => "assets/provision_node0.sh", :args => [ASSETS]
    end

    config.vm.define "node1" do |subconfig|
        subconfig.vm.hostname = "node1"
        subconfig.vm.box = BOX_IMAGE
        subconfig.vm.network :private_network, ip: NODE1_IP
        subconfig.vm.network :private_network, ip: NODE1_REPO_NET_IP
        subconfig.vm.provider "libvirt" do |libvirt|
            libvirt.driver = "kvm"
            libvirt.memory = "8096"
            libvirt.cpus = 8
            libvirt.storage_pool_name = "machines"
            # storages for cinder (vdb-vde)
            (1..4).each do |i|
                libvirt.storage :file, :size => '10G', :format => 'qcow2'
            end
            # storages for swift (vdf-vdi)
            (1..4).each do |i|
                libvirt.storage :file, :size => '20G', :format => 'qcow2'
            end
        end

        subconfig.vm.provision :reload
        subconfig.vm.provision "file", source: "assets" , destination: "/tmp/assets"
        subconfig.vm.provision :shell, :path => "assets/provision_node1.sh", :args => [ASSETS]
    end

    config.vm.define "node2" do |subconfig|
        subconfig.vm.hostname = "node2"
        subconfig.vm.box = BOX_IMAGE
        subconfig.vm.network :private_network, ip: NODE2_IP
        subconfig.vm.network :private_network, ip: NODE2_REPO_NET_IP
        subconfig.vm.provider "libvirt" do |libvirt|
            libvirt.driver = "kvm"
            libvirt.memory = "8096"
            libvirt.cpus = 4
            libvirt.storage_pool_name = "machines"
            # storages for cinder (vdb-vde)
            (1..4).each do |i|
                libvirt.storage :file, :size => '10G', :format => 'qcow2'
            end
            # storages for swift (vdf-vdi)
            (1..4).each do |i|
                libvirt.storage :file, :size => '20G', :format => 'qcow2'
            end
        end

        subconfig.vm.provision :reload
        subconfig.vm.provision "file", source: "assets" , destination: "/tmp/assets"
        subconfig.vm.provision :shell, :path => "assets/provision_node2.sh", :args => [ASSETS]
    end
end