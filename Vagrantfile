Vagrant.configure("2") do |config|
    config.vm.box = "centos/7"
    config.vm.provision :shell, :path => "init.sh"
    config.vm.network :private_network, ip: '10.0.21.31'
    config.vm.synced_folder ".", "/home/vagrant/sync", disabled: true

    config.vm.provider :virtualbox do |vb|
	vb.name = "centos7-mongo"
    end
end
