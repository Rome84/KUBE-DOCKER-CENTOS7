Vagrant.configure("2") do |config|
        config.vm.box = "centos/7"
        config.disksize.size = "300GB"
        config.vm.network "private_network", ip: "192.168.33.20"
        config.vm.hostname = "CapacityBay20"
        config.vm.provision "shell", path: "scripts/splunk-installer.sh"
        config.vm.provider "virtualbox" do |vb|
          vb.memory = "2048"
          vb.cpus = 1
        end 
  end
