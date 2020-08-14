# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

$provisioner = <<-EOF
bash /tmp/provision.sh
EOF

Vagrant.configure("2") do |config|
  config.vm.define "master" do |this|
    this.vm.provider :hyperv do |hv|
      hv.memory = 2048
      hv.cpus = 2
      hv.linked_clone = true
    end
    # this.vm.provider :hyperv do |hv|
    #   hv.memory = 2048
    #   hv.cpus = 2
    #   hv.linked_clone = true
    # end
    this.vm.box = "centos/7"
    this.vm.network "private_network"
    this.vm.hostname = "master"
    this.vm.provision "file", source: "./provision.sh", destination: "/tmp/"
    this.vm.provision "shell", inline: "bash /tmp/provision.sh master"
    this.vm.provision "file", source: "./routes.sh", destination: "/tmp/"
    this.vm.provision "shell", inline: "bash /tmp/routes.sh master"
  end
  config.vm.define "worker" do |this|
    this.vm.provider :hyperv do |hv|
      hv.memory = 2048
      hv.cpus = 2
      hv.linked_clone = true
    end
    # this.vm.provider :virtualbox do |hv|
    #   hv.memory = 2048
    #   hv.cpus = 2
    #   hv.linked_clone = true
    # end
    this.vm.box = "centos/7"
    this.vm.network "private_network"
    this.vm.hostname = "worker"
    this.vm.provision "file", source: "./provision.sh", destination: "/tmp/"
    this.vm.provision "shell", inline: "bash /tmp/provision.sh worker"
    this.vm.provision "file", source: "./routes.sh", destination: "/tmp/"
    this.vm.provision "shell", inline: "bash /tmp/routes.sh worker"
  end
end
