Vagrant.configure("2") do |config|
        config.vm.box = "centos/7"
        config.vm.network "private_network", ip: "192.168.33.28"
        config.vm.hostname = "CapacityBay-01"
        config.vm.provision "shell", path: "scripts/KUBE-DOCKER.sh"
        config.vm.provider "virtualbox" do |vb|
          vb.memory = "2048"
          vb.cpus = 1
        end 
  end
