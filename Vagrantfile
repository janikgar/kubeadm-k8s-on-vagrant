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
    this.vm.box = "centos/7"
    this.vm.network "private_network"
    this.vm.provision "file", source: "./provision.sh", destination: "/tmp/"
    this.vm.provision "shell", inline: $provisioner
  end
  config.vm.define "worker" do |this|
    this.vm.box = "centos/7"
    this.vm.network "private_network"
    this.vm.provision "file", source: "./provision.sh", destination: "/tmp/"
    this.vm.provision "shell", inline: $provisioner
  end

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"
end
