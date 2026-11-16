
Vagrant.configure("2") do |config|

  config.vm.box = "bento/ubuntu-24.04"

  config.vm.hostname = "docker-host"

  config.vm.network "private_network",
    ip: "192.168.56.30"

  config.vm.provider "vmware_desktop" do |v|
    v.memory = 4096
    v.cpus = 2
  end

end
